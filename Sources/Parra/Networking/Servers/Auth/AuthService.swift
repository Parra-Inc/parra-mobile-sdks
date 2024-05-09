//
//  AuthService.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

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

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    @discardableResult
    func login(
        authType: OAuth2Service.AuthType
    ) async -> ParraAuthResult {
        logger.debug("Logging in with username/password")

        let result: ParraAuthResult

        do {
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )

            // On login, get user info via login route instead of GET user-info
            let userInfo = try await authServer.postLogin(
                accessToken: oauthToken.accessToken
            )

            let user = ParraUser(
                credential: .oauth2(oauthToken),
                info: userInfo
            )

            result = .authenticated(user)
        } catch {
            result = .unauthenticated(error)
        }

        await applyUserUpdate(result)

        return result
    }

    @discardableResult
    func signUp(
        authType: OAuth2Service.AuthType
    ) async -> ParraAuthResult {
        logger.debug("Signing up with username/password")

        let result: ParraAuthResult

        do {
            logger
                .debug(
                    "About to sign up with: \(String(describing: authType.requestPayload))"
                )
            try await authServer.postSignup(
                requestData: authType.requestPayload
            )
            logger.debug("finished sign up endpoint... authenticating...")
            let oauthToken = try await oauth2Service.authenticate(
                using: authType
            )
            logger.debug("Finished auth endpoint")

            let userInfo = try await authServer.postLogin(
                accessToken: oauthToken.accessToken
            )

            let user = ParraUser(
                credential: .oauth2(oauthToken),
                info: userInfo
            )

            result = .authenticated(user)
        } catch {
            result = .unauthenticated(error)
        }

        await applyUserUpdate(result)

        return result
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

    // MARK: - Private

    // The actual cached token.
    private var _cachedToken: ParraUser.Credential?

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

    private func applyUserUpdate(
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
}
