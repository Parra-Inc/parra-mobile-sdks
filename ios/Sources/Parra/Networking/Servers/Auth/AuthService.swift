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
    typealias AuthProvider = () async throws -> ParraAuthState
    typealias AppleAuthCompletion = (
        Result<ASAuthorization, ASAuthorizationError>
    ) -> Void

    struct InitialAuthCheckResult {
        let requiresRefresh: Bool
        let state: ParraAuthState
    }

    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthType
    let modalScreenManager: ModalScreenManager

    var activeAuthorizationRequest: (
        ASAuthorizationController,
        AppleAuthCompletion
    )?

    let authorizationDelegateProxy =
        AuthorizationControllerDelegateProxy()

    private(set) var _cachedAuthState: ParraAuthState?

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    func login(
        authType: OAuth2Service.AuthType
    ) async throws -> ParraAuthState {
        logger.debug("Performing login", [
            "authType": authType.description
        ])

        let oauthToken = try await oauth2Service.authenticate(
            using: authType
        )

        switch authType {
        case .guest:
            // guests don't have user info to fetch, so we skip that step.
            return .guest(
                ParraGuest(
                    credential: .oauth2(oauthToken)
                )
            )
        default:
            // On login, get user info via login route instead of GET user-info
            return try await _completeLogin(
                with: oauthToken
            )
        }
    }

    func signUp(
        username: String,
        password: String,
        type: ParraIdentityType
    ) async throws -> ParraAuthState {
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

        return try await _completeLogin(
            with: oauthToken
        )
    }

    func forgotPassword(
        identity: String,
        identityType: ParraIdentityType?
    ) async throws -> Int {
        let applicationId = await authServer.appState.applicationId

        let requestData = PasswordResetChallengeRequestBody(
            clientId: applicationId,
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
        let applicationId = await authServer.appState.applicationId

        let requestData = PasswordResetRequestBody(
            clientId: applicationId,
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
                    title: ParraLabelContent(text: "Logging out..."),
                    subtitle: nil,
                    cancel: nil
                )
            )

        do {
            // Invalidate the current login

            let response = try await Parra.default.parraInternal.api.logout()

            // Logout will result in a new token for anon/guest auth.
            let oauthToken: ParraUser.Credential.Token = if let anonymousToken = response
                .anonymousToken
            {
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
            let result = try await _completeLogin(
                with: oauthToken
            )

            await applyUserUpdate(result)
        } catch {
            logger.error("Error sending logout request", error)

            await applyUserUpdate(.undetermined)
        }

        modalScreenManager.dismissLoadingIndicatorModal()
    }

    func getAuthChallenges(
        for identity: String,
        with identityType: ParraIdentityType?
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
    ) async throws -> InitialAuthCheckResult {
        let currentUser = await dataManager.getCurrentUser()

        if let currentUser {
            logger.debug("Found cached user")

            let result: ParraAuthState = if currentUser.info.isAnonymous {
                .anonymous(currentUser)
            } else {
                .authenticated(currentUser)
            }

            await applyUserUpdate(
                result,
                // Will cause double update of user state in this case.
                shouldBroadcast: false
            )

            // There was a user persisted on disk at app launch. They could be
            // out of date. Mark for refresh.
            return InitialAuthCheckResult(
                requiresRefresh: true,
                state: result
            )
        }

        // There wasn't a cached user. We have to determine an auth state. We
        // will user the app info preference on whether anonymous users are
        // supported to determine which kind of token to generate. If we fail
        // to create a token, we fall into the global auth error state.

        let result: ParraAuthState
        do {
            result = try await performUnauthenticatedLogin(
                appInfo: appInfo
            )
        } catch {
            printInvalidAuth(error: error)

            throw error
        }

        await applyUserUpdate(
            result,
            // Will cause double update of user state in this case.
            shouldBroadcast: false
        )

        return InitialAuthCheckResult(
            requiresRefresh: false,
            state: result
        )
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

        let authState: ParraAuthState = if user.info.isAnonymous {
            .anonymous(user)
        } else {
            .authenticated(user)
        }

        await applyUserUpdate(authState)

        return user
    }

    @discardableResult
    func refreshUserInfo() async throws -> ParraUser? {
        guard await dataManager.getCurrentCredential() != nil else {
            logger.debug("Can't refresh user info. No credential found.")

            return nil
        }

        logger.debug("Refreshing user info")

        let response = try await Parra.default.parraInternal.api.getUserInfo(
            timeout: 10.0
        )

        await ParraUserProperties.shared
            .forceSetStore(response.user.properties)

        await ParraUserSettings.shared
            .updateSettings(response.user.settings)

        await ParraUserEntitlements.shared
            .updateEntitlements(response.user.entitlements)

        return try await applyUserInfoUpdate(response.user)
    }

    func applyUserUpdate(
        _ authState: ParraAuthState,
        shouldBroadcast: Bool = true
    ) async {
        _cachedAuthState = authState

        switch authState {
        case .anonymous(let user):
            logger.debug("Anonymous user authenticated")

            _cachedCredential = user.credential

            await dataManager.updateCurrentUser(user)
        case .authenticated(let user):
            logger.debug("User authenticated")

            _cachedCredential = user.credential

            await dataManager.updateCurrentUser(user)
        case .guest(let guest):
            logger.debug("Guest authenticated")

            _cachedCredential = guest.credential

            await dataManager.removeCurrentUser()
        case .undetermined:
            // shouldn't ever change _to_ this state. If it does, treat it like
            // an unauth
            logger.warn("User updated changed TO undetermined state.")

            _cachedCredential = nil

            await dataManager.removeCurrentUser()
        }

        logger.trace("User update applied", [
            "broadcasting": String(shouldBroadcast)
        ])

        if shouldBroadcast {
            ParraNotificationCenter.default.post(
                name: Parra.authenticationStateDidChangeNotification,
                object: nil,
                userInfo: [
                    Parra.authenticationStateKey: authState
                ]
            )
        }
    }

    func _completeLogin(
        with oauthToken: ParraUser.Credential.Token
    ) async throws -> ParraAuthState {
        do {
            // Convert anon users by passing their refresh token along with the
            // login request.
            let anonymousToken: String? = if let _cachedCredential, case .oauth2(
                let token
            ) = _cachedCredential {
                if token.type.isAuthenticated {
                    nil
                } else {
                    token.refreshToken
                }
            } else {
                nil
            }

            if oauthToken.type == .guest {
                return .guest(
                    ParraGuest(
                        credential: .oauth2(oauthToken)
                    )
                )
            }

            let response = try await authServer.postLogin(
                accessToken: oauthToken.accessToken,
                anonymousToken: anonymousToken
            )

            let user = ParraUser(
                credential: .oauth2(oauthToken),
                info: response.user
            )

            if response.user.isAnonymous {
                return .anonymous(user)
            } else {
                return .authenticated(user)
            }
        } catch {
            logger.error("Failed to login with oauth token", error)

            throw error
        }
    }

    func getCachedAuthState() -> ParraAuthState? {
        return _cachedAuthState
    }

    /// If auth has been determined, refresh it. If it hasn't, aquire the
    /// tokens.
    func performAuthStateRefresh() {
        Task {
            guard await dataManager.getCurrentUser() != nil else {
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

            await ParraUserProperties.shared
                .forceSetStore(response.user.properties)

            await ParraUserSettings.shared
                .updateSettings(response.user.settings)

            await ParraUserEntitlements.shared
                .updateEntitlements(response.user.entitlements)

            if user.info.isAnonymous {
                await applyUserUpdate(.anonymous(user))
            } else {
                await applyUserUpdate(.authenticated(user))
            }
        }
    }

    // MARK: - Private

    // The actual cached token.
    private var _cachedCredential: ParraUser.Credential?

    /// Only for use when the refresh token has expired! Dumps local user
    /// and triggers reauthentication flow.
    private func forceLogout() async throws {
        await applyUserUpdate(.undetermined, shouldBroadcast: true)

        let appInfo = try await Parra.default.parraInternal.appInfoManager.getAppInfo()

        let result: ParraAuthState
        do {
            result = try await performUnauthenticatedLogin(
                appInfo: appInfo
            )
        } catch {
            printInvalidAuth(error: error)

            throw error
        }

        await applyUserUpdate(
            result,
            shouldBroadcast: true
        )
    }

    private func performUnauthenticatedLogin(
        appInfo: ParraAppInfo
    ) async throws -> ParraAuthState {
        let oauthType: OAuth2Service.AuthType = if appInfo.auth.supportsAnonymous {
            .anonymous(refreshToken: nil)
        } else {
            .guest(refreshToken: nil)
        }

        return try await login(authType: oauthType)
    }

    // Lazy wrapper around the cached token that will access it or try to load
    // it from disk.
    private func getCachedCredential() async -> ParraUser.Credential? {
        if let _cachedCredential {
            return _cachedCredential
        }

        if let user = await dataManager.getCurrentUser() {
            _cachedCredential = user.credential
            _cachedAuthState = if user.info.isAnonymous {
                .anonymous(user)
            } else {
                .authenticated(user)
            }

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

        do {
            let newCredential = try await getRefreshedCredential(
                forceRefresh: forceRefresh,
                timeout: timeout
            )

            await applyCredentialUpdate(newCredential)

            return newCredential
        } catch let error as ParraError {
            switch error {
            case .networkError(_, let response, let responseData):
                let status = response.statusCode

                if status == 401 {
                    logger.warn(
                        "Unauthorized error performing credential refresh",
                        error
                    )

                    try await forceLogout()

                    return nil
                }

                if let oauthError = OAuthError(
                    response: response,
                    data: responseData
                ) {
                    logger.warn(
                        "OAuth error performing credential refresh: \(oauthError.description)",
                        error
                    )

                    try await forceLogout()

                    return nil
                }

                throw error
            default:
                throw error
            }
        }
    }

    // if 400 - response "error" field - if one of codes from spec -> logout
    // if 401 - logout

    // TODO: When 401 fail and 400 check error message type. Need to logout under
    // certain circumstances. Think about how this should differ by forceRefresh

    private func getRefreshedCredential(
        forceRefresh: Bool,
        timeout: TimeInterval = 10.0
    ) async throws -> ParraUser.Credential? {
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
