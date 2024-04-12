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
        authServer: AuthServer,
        authenticationConfiguration: ParraAuthenticationConfiguration
    ) {
        self.oauth2Service = oauth2Service
        self.authServer = authServer
        self.authenticationConfiguration = authenticationConfiguration
        self.authProviderFunction = AuthService.buildProviderFunction(
            from: authenticationConfiguration,
            using: authServer
        )
    }

    // MARK: - Internal

    let oauth2Service: OAuth2Service
    let authServer: AuthServer
    let authenticationConfiguration: ParraAuthenticationConfiguration
    let authProviderFunction: ParraAuthenticationProviderFunction

    static func buildProviderFunction(
        from authenticationConfiguration: ParraAuthenticationConfiguration,
        using authServer: AuthServer
    ) -> ParraAuthenticationProviderFunction {
        let config = authenticationConfiguration

        switch config.authenticationMethod {
        case .parraAuth:
            return { () async throws -> String in
                return ""
            }
        case .custom(let authProvider):
            return { () async throws -> String in
                return try await authProvider()
            }
        case .public(
            let apiKeyId,
            let userIdProvider
        ):
            return { () async throws -> String in
                let userId = try await userIdProvider()

                return try await authServer
                    .performPublicApiKeyAuthenticationRequest(
                        forTenant: config.workspaceId,
                        apiKeyId: apiKeyId,
                        userId: userId
                    )
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

    func getCurrentCredential() async -> ParraCredential? {
        return ParraCredential(token: "token")
    }

    @discardableResult
    func refreshAuthentication() async throws -> ParraCredential {
        logger.debug("Performing reauthentication for Parra")

        do {
            logger.debug("Invoking authentication provider")

            let token = try await authProviderFunction()
            let credential = ParraCredential(token: token)

//            await dataManager.updateCredential(
//                credential: credential
//            )

            logger.debug(
                "Authentication provider returned token successfully"
            )

            onAuthStateChange(true)

            return credential
        } catch {
            onAuthStateChange(false)

            throw ParraError
                .authenticationFailed(error.localizedDescription)
        }
    }

    func onAuthStateChange(_ success: Bool) {
        for observer in observers.values {
            observer(success)
        }
    }

    func addAuthObserver(
        for key: String,
        observer: @escaping (Bool) -> Void
    ) {
        observers[key] = observer
    }

    func removeAuthObserver(for key: String) {
        observers.removeValue(forKey: key)
    }

    // MARK: - Private

    private var observers: [String: (Bool) -> Void] = [:]
}
