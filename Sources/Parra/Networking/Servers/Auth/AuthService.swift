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
        self.authTokenProvider = AuthService.buildProviderFunction(
            from: authenticationMethod,
            appState: appState,
            using: authServer,
            oauth2Service: oauth2Service
        )
    }

    // MARK: - Internal

    typealias MultiTokenProvider = () async throws -> TokenType

    enum TokenType {
        case basic(String)
        case oauth2(OAuth2Service.Token)
    }

    let appState: ParraAppState
    let oauth2Service: OAuth2Service
    let dataManager: DataManager
    let authServer: AuthServer
    let authenticationMethod: ParraAuthenticationMethod
    let authTokenProvider: MultiTokenProvider

    static func buildProviderFunction(
        from authenticationMethod: ParraAuthenticationMethod,
        appState: ParraAppState,
        using authServer: AuthServer,
        oauth2Service: OAuth2Service
    ) -> MultiTokenProvider {
        switch authenticationMethod {
        case .parraAuth:
            return {
                let result = try await oauth2Service.getToken(
                    with: OAuth2Service.PasswordCredential(
                        username: "",
                        password: " "
                    )
                )

                let token = OAuth2Service.Token(
                    accessToken: result.accessToken,
                    tokenType: result.tokenType,
                    expiresIn: result.expiresIn,
                    refreshToken: result.refreshToken
                )

                return .oauth2(token)
            }
        case .custom(let tokenProvider):
            return {
                return try await .basic(tokenProvider())
            }
        case .public(
            let apiKeyId,
            let userIdProvider
        ):
            return {
                let userId = try await userIdProvider()

                let token = try await authServer
                    .performPublicApiKeyAuthenticationRequest(
                        forTenant: appState.tenantId,
                        apiKeyId: apiKeyId,
                        userId: userId
                    )

                return .basic(token)
            }
        }
    }

    // https://auth0.com/docs/get-started/authentication-and-authorization-flow/resource-owner-password-flow

    func authenticate(
        with passwordCredential: OAuth2Service.PasswordCredential
    ) async throws {
        let response: OAuth2Service.TokenResponse = try await oauth2Service
            .getToken(
                with: passwordCredential
            )
    }

    func logout() async {}

    func loadPersistedCredential() async -> ParraUser? {
        return await dataManager.getCurrentUser()
    }

    func getCurrentCredential() async -> ParraCredential? {
        return ParraCredential(token: "token")
    }

    @discardableResult
    func refreshAuthentication() async throws -> ParraCredential {
        logger.debug("Performing reauthentication for Parra")
        logger.debug("Invoking authentication provider")

        let tokenType = try await authTokenProvider()

        let credential = switch tokenType {
        case .basic(let string):
            ParraCredential(token: string)
        case .oauth2(let token):
            ParraCredential(token: token.accessToken)
        }

        //            await dataManager.updateCredential(
        //                credential: credential
        //            )

        logger.debug(
            "Authentication provider returned token successfully"
        )

        return credential
    }
}
