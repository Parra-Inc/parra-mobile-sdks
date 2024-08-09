//
//  OAuth2Service.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

// Only refresh on launch if about to expire
// also update the api resource refresh logic to check
// if it is expired and trigger a refresh before relying on
// a 401 to indicate that the refresh should be performed.

final class OAuth2Service {
    // MARK: - Lifecycle

    init(
        clientId: String,
        tenantId: String,
        authServer: AuthServer
    ) {
        self.clientId = clientId
        self.tenantId = tenantId
        self.authServer = authServer
    }

    // MARK: - Internal

    let clientId: String
    let tenantId: String
    let authServer: AuthServer

    func authenticate(
        using authType: AuthType
    ) async throws -> ParraUser.Credential.Token {
        let tokenType = authType.tokenType

        let response: TokenResponse = switch authType {
        case .usernamePassword, .passwordlessSms, .passwordlessEmail, .webauthn:
            try await authenticateWithAccount(
                endpoint: authType.issuerEndpoint,
                authType: authType
            )
        case .anonymous, .guest:
            try await authServer.authenticateWithoutAccount(
                endpoint: authType.issuerEndpoint,
                authType: authType
            )
        }

        return ParraUser.Credential.Token(
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn,
            refreshToken: response.refreshToken,
            type: tokenType
        )
    }

    func refreshToken(
        _ token: ParraUser.Credential.Token,
        timeout: TimeInterval
    ) async throws -> ParraUser.Credential.Token {
        let refreshToken = token.refreshToken
        let endpoint = token.type.issuerEndpoint
        let tokenUrl = try createTokenUrl(
            endpoint: endpoint
        )

        if token.type == .user {
            var data: [String: String] = [
                "grant_type": "refresh_token",
                "client_id": clientId
            ]

            if let refreshToken {
                // Will always exist, except for some anonymous auth flows.
                data["refresh_token"] = refreshToken
            }

            let response: RefreshResponse = try await authServer.performFormPostRequest(
                to: tokenUrl,
                data: data,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
            )

            return ParraUser.Credential.Token(
                accessToken: response.accessToken,
                tokenType: response.tokenType,
                expiresIn: response.expiresIn,
                refreshToken: refreshToken,
                type: token.type
            )
        }

        let oauthType: OAuth2Service.AuthType = if token.type == .anonymous {
            .anonymous(refreshToken: refreshToken)
        } else {
            .guest(refreshToken: refreshToken)
        }

        let response = try await authServer.refreshWithoutAccount(
            endpoint: endpoint,
            authType: oauthType
        )

        return ParraUser.Credential.Token(
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn,
            refreshToken: refreshToken,
            type: token.type
        )
    }

    func refreshTokenIfNeeded(
        _ token: ParraUser.Credential.Token,
        timeout: TimeInterval
    ) async throws -> ParraUser.Credential.Token {
        if token.isNearlyExpired {
            if token.isExpired {
                logger.trace("Token is expired, refreshing")
            } else {
                logger.trace("Token is nearly expired, refreshing")
            }

            return try await refreshToken(
                token,
                timeout: timeout
            )
        }

        logger.trace("Token is still valid, skipping refresh")

        return token
    }

    // MARK: - Private

    private func authenticateWithAccount(
        endpoint: IssuerEndpoint,
        authType: AuthType
    ) async throws -> TokenResponse {
        var data: [String: String] = [
            "scope": "parra openid offline_access profile email phone",
            "client_id": clientId
        ]

        switch authType {
        case .usernamePassword(let email, let password):
            data["grant_type"] = "password"
            data["username"] = email
            data["password"] = password

        case .passwordlessEmail(let code):
            data["grant_type"] = "passwordless_otp"
            data["code"] = code

        case .passwordlessSms(let code):
            data["grant_type"] = "passwordless_otp"
            data["code"] = code

        case .webauthn(let code):
            data["grant_type"] = "webauthn_token"
            data["code"] = code

        default:
            break
        }

        let tokenUrl = try createTokenUrl(
            endpoint: endpoint
        )

        return try await authServer.performFormPostRequest(
            to: tokenUrl,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    private func createTokenUrl(
        endpoint: IssuerEndpoint
    ) throws -> URL {
        guard let tenant = authServer.appState.appInfo?.tenant else {
            throw ParraError.message("Missing tenant to create token url")
        }

        return try EndpointResolver.resolve(
            endpoint: endpoint,
            tenant: tenant
        )
    }
}
