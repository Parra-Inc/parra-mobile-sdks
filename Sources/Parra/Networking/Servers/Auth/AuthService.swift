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
        appState: ParraAppState,
        oauth2Service: OAuth2Service,
        dataManager: DataManager,
        authServer: AuthServer,
        authenticationMethod: ParraAuthType
    ) {
        self.appState = appState
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

    let appState: ParraAppState
    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthType

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    @discardableResult
    func login(
        username: String,
        password: String
    ) async throws -> ParraAuthResult {
        logger.debug("Logging in with username/password")

        let result: ParraAuthResult

        do {
            let oauthToken = try await oauth2Service
                .authenticate(
                    using: OAuth2Service.PasswordCredential(
                        username: username,
                        password: password
                    )
                )

            let userInfo = try await authServer.getUserInformation(
                token: oauthToken.accessToken
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
        username: String,
        password: String
    ) async throws -> ParraAuthResult {
        logger.debug("Signing up with username/password")

        let result: ParraAuthResult

        do {
            let oauthToken = try await oauth2Service
                .authenticate(
                    using: OAuth2Service.PasswordCredential(
                        username: username,
                        password: password
                    )
                )

            let userInfo = try await authServer.getUserInformation(
                token: oauthToken.accessToken
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
    func logout() async -> ParraAuthResult {
        logger.debug("Logging out")

        let result = ParraAuthResult.unauthenticated(nil)

        await applyUserUpdate(result)

        return result
    }

    func getCurrentUser() async -> ParraUser? {
        return await dataManager.getCurrentUser()
    }

    @discardableResult
    func refreshExistingToken() async throws -> String {
        // TODO: Need to bake in logic for allowing retries before propagating
        // the error.

        logger.debug("Performing reauthentication for Parra")

        let refresh: () async throws -> ParraUser.Credential? = { [self] in
            logger.debug("Invoking authentication provider")

            switch authenticationMethod {
            case .parraAuth:

                // If a token already exists, attempt to refresh it. If no token
                // exists, then we need to reauthenticate but lack the
                // credentials to handle this here.
                guard let cachedToken,
                      case .oauth2(let oauthToken) = cachedToken else
                {
                    return nil
                }

                let result = try await oauth2Service.refreshToken(
                    with: oauthToken.accessToken
                )

                return .oauth2(result)
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
                        forTenant: appState.tenantId,
                        apiKeyId: apiKeyId,
                        userId: userId
                    )

                return .basic(token)
            }
        }

        guard let credential = try await refresh() else {
            // The refresh token provider returning nil indicates that a
            // logout should take place.

            Task {
                await logout()
            }

            throw ParraError.authenticationFailed(
                "Failed to refresh token"
            )
        }

        let accessToken = credential.accessToken

        let userInfo = try await authServer.getUserInformation(
            token: accessToken
        )

        let user = ParraUser(
            credential: credential,
            info: userInfo
        )

        await applyUserUpdate(.authenticated(user))

        return accessToken
    }

    // MARK: - Private

    private var cachedToken: ParraUser.Credential?

    private func applyUserUpdate(
        _ authResult: ParraAuthResult
    ) async {
        switch authResult {
        case .authenticated(let parraUser):
            logger.debug("User authenticated: \(parraUser)")

            await dataManager.updateCurrentUser(parraUser)
        case .unauthenticated(let error):
            logger.debug("User unauthenticated: \(String(describing: error))")

            await dataManager.removeCurrentUser()
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
