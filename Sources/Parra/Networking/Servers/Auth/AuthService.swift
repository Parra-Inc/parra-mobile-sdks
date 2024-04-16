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
        authenticationMethod: ParraAuthenticationMethod
    ) {
        self.appState = appState
        self.oauth2Service = oauth2Service
        self.dataManager = dataManager
        self.authServer = authServer
        self.authenticationMethod = authenticationMethod
    }

    // MARK: - Internal

    typealias MultiTokenProvider = () async throws -> TokenType?
    typealias AuthProvider = () async throws -> ParraAuthResult

    // 1. Function to convert an authentication method to a token provider.
    // 2. Function to invoke a token provider and get an auth result.

    enum TokenType {
        case basic(String)
        case oauth2(OAuth2Service.Token)
    }

    let appState: ParraAppState
    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthenticationMethod

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    @discardableResult
    func login(
        username: String,
        password: String
    ) async throws -> ParraAuthResult {
        let result: ParraAuthResult

        do {
            let response: OAuth2Service.TokenResponse = try await oauth2Service
                .authenticate(
                    using: OAuth2Service.PasswordCredential(
                        username: username,
                        password: password
                    )
                )

            let userInfo = try await authServer.getUserInformation(
                token: response.accessToken
            )

            let user = ParraUser(
                credential: ParraUser.Credential(
                    token: response.accessToken
                ),
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

        let refresh: () async throws -> TokenType? = { [self] in
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

                return .oauth2(
                    OAuth2Service.Token(
                        accessToken: result.accessToken,
                        tokenType: result.tokenType,
                        expiresIn: result.expiresIn,
                        refreshToken: oauthToken.refreshToken
                    )
                )
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

        guard let token = try await refresh() else {
            // The refresh token provider returning nil indicates that a
            // logout should take place.

            Task {
                await logout()
            }

            throw ParraError.authenticationFailed(
                "Failed to refresh token"
            )
        }

        switch token {
        case .basic(let accessToken):
            return accessToken
        case .oauth2(let token):
            return token.accessToken
        }
    }

    // MARK: - Private

    private var cachedToken: TokenType?

    private func applyUserUpdate(
        _ authResult: ParraAuthResult
    ) async {
        switch authResult {
        case .authenticated(let parraUser):
            await dataManager.updateCurrentUser(parraUser)
        case .unauthenticated:
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
