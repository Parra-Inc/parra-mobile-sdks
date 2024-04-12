//
//  OAuth2Service.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let tokenUrl = URL(string: "https://auth.parra.io/oauth/token")!

final class OAuth2Service {
    // MARK: - Lifecycle

    init(
        clientId: String,
        authServer: AuthServer
    ) {
        self.clientId = clientId
        self.authServer = authServer
    }

    // MARK: - Internal

    let clientId: String
    let authServer: AuthServer

    func getToken(
        with passwordCredential: PasswordCredential
    ) async throws -> TokenResponse {
        let data: [String: String] = [
            "grant_type": "password",
            "username": passwordCredential.username,
            "password": passwordCredential.password,
            "audience": "api.parra.io",
            "scope": "offline_access",
            "client_id": clientId
        ]

        return try await authServer.performFormPostRequest(
            to: tokenUrl,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            delegate: nil
        )
    }

    func refreshToken(
        with refreshToken: String
    ) async throws -> RefreshResponse {
        let data: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

        return try await authServer.performFormPostRequest(
            to: tokenUrl,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            delegate: nil
        )
    }
}
