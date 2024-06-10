//
//  AuthService.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation

private let logger = Logger()

typealias AppleAuthCompletion = (Result<ASAuthorization, ASAuthorizationError>)
    -> Void

final class AuthService {
    // MARK: - Lifecycle

    init(
        oauth2Service: OAuth2Service,
        dataManager: DataManager,
        authServer: AuthServer,
        authenticationMethod: ParraAuthType
    ) {
        self.oauth2Service = oauth2Service
        self.dataManager = dataManager
        self.authServer = authServer
        self.authenticationMethod = authenticationMethod
    }

    // MARK: - Internal

    typealias MultiTokenProvider = () async throws -> ParraUser.Credential?
    typealias AuthProvider = () async throws -> ParraAuthResult

    // 1. Function to convert an authentication method to a token provider.
    // 2. Function to invoke a token provider and get an auth result.

    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthType

    private(set) var activeAuthorizationRequests: [
        UnsafeMutableRawPointer: (
            ASAuthorizationController,
            AppleAuthCompletion
        )
    ] = [:]

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    func login(
        authType: OAuth2Service.AuthType
    ) async -> ParraAuthResult {
        logger.debug("Logging in with username/password")

        do {
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )

            // On login, get user info via login route instead of GET user-info
            return await completeLogin(
                with: oauthToken
            )
        } catch {
            return .unauthenticated(error)
        }
    }

    func loginWithPasskey(
        username: String?,
        presentationMode: PasskeyPresentationMode,
        using appInfo: ParraAppInfo
    ) async throws {
        let (
            request,
            session
        ) = try await createPublicKeyCredentialAssertionRequest(
            for: username
        )

        // begin authorization needs to be promise, return result. Look at result
        // to determine if proceed to login or navigate

        let authorization = try await beginAuthorization(
            for: [request],
            using: presentationMode
        )

        // TODO: Handle the authorization result
//        await applyUserUpdate(.authenticated(user))
    }

    func registerWithPasskey(
        username: String
    ) async throws {
        let (
            request,
            session
        ) = try await createPublicKeyCredentialRegistrationRequest(
            for: username
        )

        let authorization = try await beginAuthorization(
            for: [request],
            using: .modal
        )

        // TODO: If user already exists error, login? 409 from server or apple error?

        let accessToken = try await processPasskeyAuthorization(
            authorization: authorization,
            session: session
        )

        let authResult = await login(
            authType: .webauthn(code: accessToken)
        )

        await applyUserUpdate(authResult)
    }

    func linkPasskeyToAccount() async throws {}

    func cancelPasskeyRequests() {
        // Cancel active requests by calling cancel on the authorization
        // controllers they are attached to. This will cause the authorization
        // delegate to fire an error -> cancelled, which will resolve the
        // completion handlers and remove the requests.
        for (_, value) in activeAuthorizationRequests {
            value.0.cancel()
        }
    }

    func signUp(
        username: String,
        password: String,
        type: IdentityType
    ) async -> ParraAuthResult {
        logger.debug("Signing up with username/password")

        let authType = OAuth2Service.AuthType.usernamePassword(
            username: username,
            password: password
        )

        let requestPayload = CreateUserRequestBody(
            type: type,
            username: username,
            password: password
        )

        do {
            logger
                .debug(
                    "About to sign up with: \(String(describing: requestPayload))"
                )
            try await authServer.postSignup(
                requestData: requestPayload
            )
            logger.debug("finished sign up endpoint... authenticating...")
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )
            logger.debug("Finished auth endpoint")

            return await completeLogin(
                with: oauthToken
            )
        } catch {
            return .unauthenticated(error)
        }
    }

    func logout() async {
        logger.debug("Logging out")

        guard let credential = await getCachedCredential() else {
            return
        }

        Task.detached {
            do {
                try await self.authServer.postLogout(
                    accessToken: credential.accessToken
                )
            } catch {
                logger.error("Error sending logout request", error)
            }
        }

        await applyUserUpdate(.unauthenticated(nil))
    }

    func getAuthChallenges(
        for identity: String,
        with identityType: IdentityType?
    ) async throws -> AuthChallengeResponse {
        let body = AuthChallengesRequestBody(
            identity: identity,
            identityType: identityType
        )

        return try await authServer.postAuthChallenges(
            requestData: body
        )
    }

    func passwordlessSendCode(
        email: String? = nil,
        phoneNumber: String? = nil
    ) async throws -> ParraPasswordlessChallengeResponse {
        logger.debug("Sending passwordless code", [
            "email": email ?? "nil",
            "phoneNumber": phoneNumber ?? "nil"
        ])

        if email == nil, phoneNumber == nil {
            throw ParraError.message(
                "Either email or phone number must be provided"
            )
        }

        let body = PasswordlessChallengeRequestBody(
            clientId: authServer.appState.applicationId,
            email: email,
            phoneNumber: phoneNumber
        )

        return try await authServer.postPasswordless(
            requestData: body
        )
    }

    func passwordlessVerifyCode(
        type: ParraAuthenticationMethod.PasswordlessType,
        code: String
    ) async throws -> ParraAuthResult {
        logger.debug("Confirming passwordless code")

        let authType: OAuth2Service.AuthType = switch type {
        case .sms:
            .passwordlessSms(code: code)
        case .email:
            .passwordlessEmail(code: code)
        }

        do {
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )

            // On login, get user info via login route instead of GET user-info
            return await completeLogin(
                with: oauthToken
            )
        } catch {
            return .unauthenticated(error)
        }
    }

    func getCurrentUser() async -> ParraUser? {
        return await dataManager.getCurrentUser()
    }

    // App launches
    // Show launch while loading state
    // when state loads, check if auth'd
    // if auth'd show app and refresh auth
    // if refresh fails, stay logged in unless 401, then logout

    // parra auth ->

    // public key -> 401 -> retry -> 401 -> logout
    // public key -> user id provider fails -> logout after retry (any error)

    // custom -> 401 -> logout
    // custom -> other error -> retry logout if failed

    /// Fetches the cached token, or refreshes the cached token and returns the
    /// result if the current token is expired. Does **not** refresh user info
    func getAccessTokenRefreshingIfNeeded() async throws -> String {
        guard await getCachedCredential() != nil else {
            return try await getRefreshedToken()
        }

        guard let newCredential = try await performCredentialRefresh(
            forceRefresh: false
        ) else {
            throw ParraError.authenticationFailed(
                "Failed to refresh token"
            )
        }

        return newCredential.accessToken
    }

    /// Forces a refresh of the current token, if one exists and returns the
    /// result. Does **not** refresh user info.
    func getRefreshedToken() async throws -> String {
        guard let newCredential = try await performCredentialRefresh(
            forceRefresh: true
        ) else {
            throw ParraError.authenticationFailed(
                "Failed to refresh token"
            )
        }

        return newCredential.accessToken
    }

    /// Meant specifically for the case where the app is launching and we want
    /// to refresh credentials before proceeding. Very short timeouts are used
    /// for network requests so they can fail quickly and all the user to
    /// proceed into the app.
    func performAppLaunchTokenAndUserRefresh() async throws {
        logger.debug("Performing reauthentication for Parra")

        // Using a short timeout since these requests are made on app launch
        let timeout: TimeInterval = 5.0

        guard let credential = try await performCredentialRefresh(
            forceRefresh: false,
            timeout: timeout
        ) else {
            // The refresh token provider returning nil indicates that a
            // logout should take place.

            Task {
                await logout()
            }

            throw ParraError.authenticationFailed(
                "Failed to refresh token"
            )
        }

        let userInfo = try await authServer.getUserInfo(
            accessToken: credential.accessToken,
            timeout: timeout
        )

        let user = ParraUser(
            credential: credential,
            info: userInfo
        )

        await applyUserUpdate(.authenticated(user))
    }

    func applyUserUpdate(
        _ authResult: ParraAuthResult
    ) async {
        switch authResult {
        case .authenticated(let parraUser):
            logger.debug("User authenticated: \(parraUser)")

            await dataManager.updateCurrentUser(parraUser)

            _cachedToken = parraUser.credential
        case .unauthenticated(let error):
            logger
                .debug(
                    "User unauthenticated with error: \(String(describing: error))"
                )

            await dataManager.removeCurrentUser()

            _cachedToken = nil
        }

        ParraNotificationCenter.default.post(
            name: Parra.authenticationStateDidChangeNotification,
            object: nil,
            userInfo: [
                Parra.authenticationStateKey: authResult
            ]
        )
    }

    // MARK: - Private

    // The actual cached token.
    private var _cachedToken: ParraUser.Credential?
    private let authorizationDelegateProxy =
        AuthorizationControllerDelegateProxy()

    private func processPasskeyAuthorization(
        authorization: ASAuthorization,
        session: String
    ) async throws -> String {
        if let credential = authorization
            .credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration
        {
            let id = credential.credentialID.base64urlEncodedString()
            let clientData = credential.rawClientDataJSON
                .base64urlEncodedString()

            guard let rawAttestationObject = credential.rawAttestationObject else {
                throw ParraError.message("Failed to decode attestation object")
            }

            let attestationObject = rawAttestationObject
                .base64urlEncodedString()

            let response = try await authServer.postWebAuthnRegister(
                requestData: WebauthnRegisterRequestBody(
                    id: id,
                    rawId: id,
                    response: AuthenticatorAttestationResponse(
                        clientDataJSON: clientData,
                        attestationObject: attestationObject
                    ),
                    type: "public-key",
                    user: nil
                ),
                session: session
            )

            return response.token
        } else if let credential = authorization
            .credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion
        {
            // Take steps to verify the challenge.
            let dataString = String(
                data: credential.rawClientDataJSON,
                encoding: .utf8
            )!

            print("-------------------------------")
            print(dataString)

            return ""
        } else {
            throw ParraError.message(
                "Unhandled authorization credential type"
            )
        }
    }

    private func beginAuthorization(
        for authorizationRequests: [ASAuthorizationRequest],
        using presentationMode: PasskeyPresentationMode
    ) async throws -> ASAuthorization {
        if !activeAuthorizationRequests.isEmpty {
            logger.debug("Apple authorization requests already in progress")

            cancelPasskeyRequests()
        }

        return try await withCheckedThrowingContinuation { continuation in
            performAuthorization(
                for: authorizationRequests,
                using: .modal
            ) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func performAuthorization(
        for authorizationRequests: [ASAuthorizationRequest],
        using presentationMode: PasskeyPresentationMode,
        completion: @escaping AppleAuthCompletion
    ) {
        let activeAuthorizationController = ASAuthorizationController(
            authorizationRequests: authorizationRequests
        )

        authorizationDelegateProxy.authService = self
        activeAuthorizationController.delegate = authorizationDelegateProxy
        activeAuthorizationController
            .presentationContextProvider = authorizationDelegateProxy

        switch presentationMode {
        case .modal:
            // This will display the passkey prompt, only if the user
            // already has a passkey. If they don't an error will be sent
            // to the delegate, which we will ignore. If the user didn't
            // have a passkey, they probably don't want the popup, and they
            // will have the opportunity to create one later.
            activeAuthorizationController.performRequests(
                options: .preferImmediatelyAvailableCredentials
            )
        case .autofill:
            // to display in quicktype
            activeAuthorizationController.performAutoFillAssistedRequests()
        }

        let addr = Unmanaged.passUnretained(activeAuthorizationController)
            .toOpaque()

        activeAuthorizationRequests[addr] = (
            activeAuthorizationController,
            completion
        )
    }

    private func createPublicKeyCredentialRegistrationRequest(
        for username: String
    ) async throws
        -> (
            ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest,
            String
        )
    {
        let (challengeResponse, session) = try await authServer
            .postWebAuthnRegisterChallenge(
                requestData: WebAuthnRegisterChallengeRequest(
                    username: username
                )
            )

        let relyingPartyIdentifier = challengeResponse.rp.id
        let userId = Data(challengeResponse.user.id.utf8)

        guard let challengeData = Data(
            base64urlEncoded: challengeResponse.challenge
        ) else {
            throw ParraError.message("Failed to decode challenge")
        }

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: relyingPartyIdentifier
        )

        let request = provider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: username,
            userID: userId
        )

        return (request, session)
    }

    private func createPublicKeyCredentialAssertionRequest(
        for username: String?
    ) async throws
        -> (ASAuthorizationPlatformPublicKeyCredentialAssertionRequest, String)
    {
        let (challengeResponse, session) = try await authServer
            .postWebAuthnAuthenticateChallenge(
                requestData: WebAuthnAuthenticateChallengeRequest(
                    username: username
                )
            )

        guard
            let relyingPartyIdentifier = challengeResponse.rpId,
            let rpUrl = URL(string: relyingPartyIdentifier) else
        {
            throw ParraError.message("Missing relying party identifier")
        }

        // Server should return rpId as a host string but we've had issues where
        // this has changed to include a scheme. It MUST be a host string when
        // we pass it to the ASAuthorizationPlatformPublicKeyCredentialProvider.
//        guard let rpHost = rpUrl.host(percentEncoded: false) else {
//            throw ParraError.message("Failed to extract host from rpId")
//        }

        let challenge = Data(challengeResponse.challenge.utf8)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: relyingPartyIdentifier
        )

        let request = provider.createCredentialAssertionRequest(
            challenge: challenge
        )

        // used when we have context about the user, like when they've typed in their username
        let allowCredentials = challengeResponse.allowCredentials ?? []
        request.allowedCredentials = allowCredentials.map { credential in
            return ASAuthorizationPlatformPublicKeyCredentialDescriptor(
                credentialID: Data(credential.id.utf8)
            )
        }

        return (request, session)
    }

    // Lazy wrapper around the cached token that will access it or try to load
    // it from disk.
    private func getCachedCredential() async -> ParraUser.Credential? {
        if let _cachedToken {
            return _cachedToken
        }

        if let user = await dataManager.getCurrentUser() {
            _cachedToken = user.credential

            return _cachedToken
        }

        return nil
    }

    /// - Parameter forceRefresh: Only relevant to the OAuth flow. All others
    /// refresh every time anyway.
    private func performCredentialRefresh(
        forceRefresh: Bool,
        timeout: TimeInterval = 10.0
    ) async throws -> ParraUser.Credential? {
        logger.debug("Invoking authentication provider")

        let performRefresh = { [self] () -> ParraUser.Credential? in
            switch authenticationMethod {
            case .parraAuth:

                // If a token already exists, attempt to refresh it. If no token
                // exists, then we need to reauthenticate but lack the
                // credentials to handle this here.
                guard let cachedToken = await getCachedCredential() else {
                    return nil
                }

                switch cachedToken {
                case .basic:
                    // The cached token is not an OAuth2 token, so we cannot
                    // refresh it. This shouldn't happen, but returning nil
                    // will trigger a logout.

                    return nil
                case .oauth2(let token):
                    let result: OAuth2Service.Token = if forceRefresh {
                        try await oauth2Service.refreshToken(
                            token,
                            timeout: timeout
                        )
                    } else {
                        try await oauth2Service.refreshTokenIfNeeded(
                            token,
                            timeout: timeout
                        )
                    }

                    return .oauth2(result)
                }
            case .custom(let tokenProvider):
                // Does not support refreshing. Must just reinvoke and use the
                // new token.

                guard let accessToken = try await tokenProvider() else {
                    return nil
                }

                return .basic(accessToken)
            case .public(let apiKeyId, let userIdProvider):
                // Does not support refreshing. Must just reinvoke and use the
                // new token.

                guard let userId = try await userIdProvider() else {
                    return nil
                }

                let token = try await authServer
                    .performPublicApiKeyAuthenticationRequest(
                        apiKeyId: apiKeyId,
                        userId: userId,
                        timeout: timeout
                    )

                return .basic(token)
            }
        }

        let newCredential = try await performRefresh()

        await applyCredentialUpdate(newCredential)

        return newCredential
    }

    private func applyCredentialUpdate(
        _ credential: ParraUser.Credential?
    ) async {
        guard let credential else {
            _cachedToken = nil

            return
        }

        switch credential {
        case .basic(let token):
            _cachedToken = .basic(token)
        case .oauth2(let token):
            _cachedToken = .oauth2(token)
        }

        await dataManager.updateCurrentUserCredential(credential)
    }

    private func completeLogin(
        with oauthToken: OAuth2Service.Token
    ) async -> ParraAuthResult {
        do {
            let userInfo = try await authServer.postLogin(
                accessToken: oauthToken.accessToken
            )

            let user = ParraUser(
                credential: .oauth2(oauthToken),
                info: userInfo
            )

            return .authenticated(user)
        } catch {
            logger.error("Failed to login with oauth token", error)

            return .unauthenticated(error)
        }
    }
}
