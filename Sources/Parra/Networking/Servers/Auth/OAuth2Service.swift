//
//  OAuth2Service.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class OAuth2Service {
    // MARK: - Lifecycle

    init(
        clientId: String,
        tenantId: String,
        authServer: AuthServer
    ) {
        self.clientId = clientId
        self.authServer = authServer
        self.tokenUrl = URL(
            string: "https://tenant-\(tenantId).parra.io/auth/token"
        )!
    }

    // MARK: - Internal

    let clientId: String
    let tokenUrl: URL
    let authServer: AuthServer

    func authenticate(
        using passwordCredential: PasswordCredential
    ) async throws -> Token {
        let data: [String: String] = [
            "grant_type": "password",
            "username": passwordCredential.username,
            "password": passwordCredential.password,
            "audience": "api.parra.io",
            "scope": "offline_access",
            "client_id": clientId
        ]

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

//    func signUp() -> TenantUser {
//        return TenantUser()
//    }

    func refreshToken(
        with refreshToken: String
    ) async throws -> Token {
        let data: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

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
}
