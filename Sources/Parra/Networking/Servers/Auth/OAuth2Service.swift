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
        self.authServer = authServer
    }

    // MARK: - Internal

    let clientId: String
    let authServer: AuthServer

    func authenticate(
        using signupType: AuthType
    ) async throws -> Token {
        var data: [String: String] = [
            "scope": "parra openid offline_access profile email phone",
            "client_id": clientId
        ]

        switch signupType {
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
        }

        let tokenUrl = try createTokenUrl()
        let response: TokenResponse = try await authServer
            .performFormPostRequest(
                to: tokenUrl,
                data: data,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                delegate: nil
            )

        return OAuth2Service.Token(
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn,
            refreshToken: response.refreshToken
        )
    }

    func refreshToken(
        _ token: Token,
        timeout: TimeInterval
    ) async throws -> Token {
        let refreshToken = token.refreshToken

        let data: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

        let tokenUrl = try createTokenUrl()
        let response: RefreshResponse = try await authServer
            .performFormPostRequest(
                to: tokenUrl,
                data: data,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                delegate: nil
            )

        return OAuth2Service.Token(
            accessToken: response.accessToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn,
            refreshToken: refreshToken
        )
    }

    func refreshTokenIfNeeded(
        _ token: Token,
        timeout: TimeInterval
    ) async throws -> Token {
        if token.isNearlyExpired {
            if token.isExpired {
                logger.trace("Token is expired, refreshing")
            } else {
                logger.trace("Token is nearly expired, refreshing")
            }

            return try await refreshToken(token, timeout: timeout)
        }

        logger.trace("Token is still valid, skipping refresh")

        return token
    }

    // MARK: - Private

    private func createTokenUrl() throws -> URL {
        guard
            let issuer = authServer.appState.appInfo?.tenant.issuer,
            let tokenUrl = URL(string: "\(issuer)/auth/token") else
        {
            throw ParraError.message("Failed to construct token URL")
        }

        return tokenUrl
    }
}
