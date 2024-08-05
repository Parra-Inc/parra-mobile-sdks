//
//  AuthService.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import Foundation
import os

private let logger = Logger()

final class AuthService {
    // MARK: - Lifecycle

    init(
        oauth2Service: OAuth2Service,
        dataManager: DataManager,
        authServer: AuthServer,
        authenticationMethod: ParraAuthType,
        modalScreenManager: ModalScreenManager
    ) {
        self.oauth2Service = oauth2Service
        self.dataManager = dataManager
        self.authServer = authServer
        self.authenticationMethod = authenticationMethod
        self.modalScreenManager = modalScreenManager
    }

    // MARK: - Internal

    struct AuthorizationRequestContext {
        let controller: ASAuthorizationController
        let completion: AppleAuthCompletion
    }

    typealias MultiTokenProvider = () async throws -> ParraUser.Credential?
    typealias AuthProvider = () async throws -> ParraAuthResult
    typealias AppleAuthCompletion = (
        Result<ASAuthorization, ASAuthorizationError>
    ) -> Void

    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthType
    let modalScreenManager: ModalScreenManager

    var activeAuthorizationRequests: [
        UnsafeMutableRawPointer: (
            ASAuthorizationController,
            AppleAuthCompletion
        )
    ] = [:]

    let authorizationDelegateProxy =
        AuthorizationControllerDelegateProxy()

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    func login(
        authType: OAuth2Service.AuthType
    ) async -> ParraAuthResult {
        logger.debug("Performing login", [
            "authType": authType.description
        ])

        do {
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )

            switch authType {
            case .guest(let refreshToken):
                // guests don't have user info to fetch, so we skip that step.
                return .guest(
                    ParraGuest(
                        credential: .oauth2(oauthToken)
                    )
                )
            default:
                // On login, get user info via login route instead of GET user-info
                return await _completeLogin(
                    with: oauthToken
                )
            }
        } catch {
            return .error(error)
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

            return await _completeLogin(
                with: oauthToken
            )
        } catch {
            return .error(error)
        }
    }

    func forgotPassword(
        identity: String,
        identityType: IdentityType?
    ) async throws -> Int {
        let requestData = PasswordResetChallengeRequestBody(
            clientId: authServer.appState.applicationId,
            identity: identity,
            identityType: identityType
        )

        let response = try await authServer.postForgotPassword(
            requestData: requestData
        )

        return response.statusCode
    }

    func resetPassword(
        code: String,
        password: String
    ) async throws {
        let requestData = PasswordResetRequestBody(
            clientId: authServer.appState.applicationId,
            code: code,
            password: password
        )

        try await authServer.postResetPassword(
            requestData: requestData
        )
    }

    func logout() async {
        guard case .parra = authenticationMethod else {
            logger
                .warn(
                    "Parra authentication wasn't used. Skipping logout in Parra auth service."
                )
            return
        }

        logger.debug("Logging out")

        modalScreenManager
            .presentLoadingIndicatorModal(
                content: .init(
                    title: LabelContent(text: "Logging out..."),
                    subtitle: nil,
                    cancel: nil
                )
            )

        do {
            // Invalidate the current login

            let response = try await Parra.default.parraInternal.api.logout()

            // Logout will result in a new token for anon/guest auth.
            let oauthToken: ParraUser.Credential.Token = if let anonymousToken = response.anonymousToken {
                .init(authToken: anonymousToken, type: .anonymous)
            } else if let guestToken = response.guestToken {
                .init(authToken: guestToken, type: .guest)
            } else {
                throw ParraError.message("Logout didn't produce valid token.")
            }

            logger.debug("Logout resulted in unauthenticated account with type", [
                "type": oauthToken.type.description
            ])

            // Login as either anon or guest depending on config.
            let result = await _completeLogin(
                with: oauthToken
            )

            await applyUserUpdate(result)
        } catch {
            logger.error("Error sending logout request", error)

            await applyUserUpdate(.error(error))
        }

        modalScreenManager.dismissLoadingIndicatorModal()
    }

    func forceLogout(
        from error: Error
    ) async {
        logger.error("Forcing logout due to error", error)

        await applyUserUpdate(.error(error))
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

    /// If there is a user cached, return what we already have
    /// Meant specifically for the case where the app is launching and we want
    /// to refresh credentials before proceeding. Very short timeouts are used
    /// for network requests so they can fail quickly and all the user to
    /// proceed into the app.
    func getQuickestAuthState(
        appInfo: ParraAppInfo
    ) async -> ParraAuthResult {
        // If we encounter a state that requires refreshing user info or tokens
        // asynchronously while allowing this method to return so app state
        // may proceed.
        var shouldRefresh = false

        defer {
            if shouldRefresh {
                performAuthStateRefresh()
            }
        }

        let currentUser = await dataManager.getCurrentUser()

        if let currentUser {
            logger.debug("Found cached user")

            // There was a user persisted on disk at app launch. They could be
            // out of date.
            shouldRefresh = true

            let result: ParraAuthResult = if currentUser.info.isAnonymous {
                .anonymous(currentUser)
            } else {
                .authenticated(currentUser)
            }

            await applyUserUpdate(
                result,
                // Will cause double update of user state in this case.
                shouldBroadcast: false
            )

            return result
        }

        // There wasn't a cached user. We have to determine an auth state. We
        // will user the app info preference on whether anonymous users are
        // supported to determine which kind of token to generate. If we fail
        // to create a token, we fall into the global auth error state.

        let result: ParraAuthResult
        do {
            result = try await performUnauthenticatedLogin(
                appInfo: appInfo
            )
        } catch {
            printInvalidAuth(error: error)

            result = .error(error)
        }

        await applyUserUpdate(
            result,
            // Will cause double update of user state in this case.
            shouldBroadcast: false
        )

        return result
    }

    private func performUnauthenticatedLogin(
        appInfo: ParraAppInfo
    ) async throws -> ParraAuthResult {
        let oauthType: OAuth2Service.AuthType = if appInfo.auth.supportsAnonymous {
            .anonymous(refreshToken: nil)
        } else {
            .guest(refreshToken: nil)
        }

        return try await login(authType: oauthType)
    }

    /// If auth has been determined, refresh it. If it hasn't, aquire the
    /// tokens.
    private func performAuthStateRefresh() {
        Task {
            guard let currentUser = await dataManager.getCurrentUser() else {
                // The only way this will happen is if the getQuickestAuthState
                // flow resulted in an error, in which case there's no valid
                // state to refresh.

                return
            }

            // printInvalidAuth(error: error)
            logger.debug("Performing reauthentication for Parra")

            // Using a short timeout since these requests are made on app launch
            let timeout: TimeInterval = 5.0

            guard let credential = try await performCredentialRefresh(
                forceRefresh: false,
                timeout: timeout
            ) else {
                // The refresh token provider returning nil indicates that a
                // logout should take place.

                await logout()

                return
            }

            // Must updated persisted credential before get user info api call
            // since API service requires being able to load this value.
            await dataManager.updateCurrentUserCredential(credential)

            let response = try await Parra.default.parraInternal.api.getUserInfo(
                timeout: timeout
            )

            let user = ParraUser(
                credential: credential,
                info: response.user
            )

            await applyUserUpdate(.authenticated(user))
        }
    }

    @discardableResult
    func applyUserInfoUpdate(
        _ info: ParraUser.Info
    ) async throws -> ParraUser? {
        guard let credential = await dataManager.getCurrentCredential() else {
            logger.debug("Can't apply user info update. No credential found.")

            return nil
        }

        let user = ParraUser(
            credential: credential,
            info: info
        )

        await applyUserUpdate(.authenticated(user))

        return user
    }

    @discardableResult
    func refreshUserInfo() async throws -> ParraUser? {
        guard let credential = await dataManager.getCurrentCredential() else {
            logger.debug("Can't refresh user info. No credential found.")

            return nil
        }

        logger.debug("Refreshing user info")

        let response = try await Parra.default.parraInternal.api.getUserInfo(
            timeout: 10.0
        )

        return try await applyUserInfoUpdate(response.user)
    }

    func applyUserUpdate(
        _ authResult: ParraAuthResult,
        shouldBroadcast: Bool = true
    ) async {
        switch authResult {
        case .anonymous(let user):
            logger.debug("Anonymous user authenticated")

            await dataManager.updateCurrentUser(user)

            _cachedCredential = user.credential
        case .authenticated(let user):
            logger.debug("User authenticated")

            await dataManager.updateCurrentUser(user)

            _cachedCredential = user.credential
        case .guest(let guest):
            logger.debug("Guest authenticated")

            await dataManager.removeCurrentUser()

            _cachedCredential = guest.credential
        case .error(let error):
            logger
                .debug(
                    "User unauthenticated with error: \(String(describing: error))"
                )

            await dataManager.removeCurrentUser()

            _cachedCredential = nil
        case .undetermined:
            // shouldn't ever change _to_ this state. If it does, treat it like
            // an unauth
            logger.warn("User updated changed TO undetermined state.")

            await dataManager.removeCurrentUser()

            _cachedCredential = nil
        }

        if shouldBroadcast {
            ParraNotificationCenter.default.post(
                name: Parra.authenticationStateDidChangeNotification,
                object: nil,
                userInfo: [
                    Parra.authenticationStateKey: authResult
                ]
            )
        }
    }

    func _completeLogin(
        with oauthToken: ParraUser.Credential.Token
    ) async -> ParraAuthResult {
        do {
            // Convert anon users by passing their refresh token along with the
            // login request.
            let anonymousToken: String? = if let _cachedCredential, case let .oauth2(
                token
            ) = _cachedCredential {
                if token.type.isAuthenticated {
                    nil
                } else {
                    token.refreshToken
                }
            } else {
                nil
            }

            let response = try await authServer.postLogin(
                accessToken: oauthToken.accessToken,
                anonymousToken: anonymousToken
            )

            let user = ParraUser(
                credential: .oauth2(oauthToken),
                info: response.user
            )

            return .authenticated(user)
        } catch {
            logger.error("Failed to login with oauth token", error)

            return .error(error)
        }
    }

    // MARK: - Private

    // The actual cached token.
    private var _cachedCredential: ParraUser.Credential?

    // Lazy wrapper around the cached token that will access it or try to load
    // it from disk.
    private func getCachedCredential() async -> ParraUser.Credential? {
        if let _cachedCredential {
            return _cachedCredential
        }

        if let user = await dataManager.getCurrentUser() {
            _cachedCredential = user.credential

            return _cachedCredential
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
            case .parra:

                // If a token already exists, attempt to refresh it. If no token
                // exists, then we need to reauthenticate but lack the
                // credentials to handle this here.
                guard let cachedCredential = await getCachedCredential() else {
                    return nil
                }

                switch cachedCredential {
                case .basic:
                    // The cached token is not an OAuth2 token, so we cannot
                    // refresh it. This shouldn't happen, but returning nil
                    // will trigger a logout.

                    return nil
                case .oauth2(let token):
                    let result: ParraUser.Credential.Token = if forceRefresh {
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
            _cachedCredential = nil

            return
        }

        switch credential {
        case .basic(let token):
            _cachedCredential = .basic(token)
        case .oauth2(let token):
            _cachedCredential = .oauth2(token)
        }

        await dataManager.updateCurrentUserCredential(credential)
    }

    private func printInvalidAuth(error: Error) {
        let printDefaultError: () -> Void = {
            logger.error(
                "Authentication handler in call to Parra.initialize failed",
                error
            )
        }

        guard let parraError = error as? ParraError else {
            printDefaultError()

            return
        }

        switch parraError {
        case .authenticationFailed(let underlying):
            let systemLogger = os.Logger(
                subsystem: "Parra",
                category: "initialization"
            )

            // Bypassing main logger here because we won't want to include the
            // normal formatting/backtrace/etc. We want to display as clear of
            // a message as is possible. Note the exclamations prevent
            // whitespace trimming from removing the padding newlines.
            systemLogger.log(
                level: .fault,
                "!\n\n\n\n\n\n\nERROR INITIALIZING PARRA!\nThe authentication provider passed to ParraApp returned an error. The user was unable to be verified.\n\nUnderlying error:\n\(underlying)\n\n\n\n\n\n\n!"
            )
        default:
            printDefaultError()
        }
    }
}
