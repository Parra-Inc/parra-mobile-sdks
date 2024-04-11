//
//  OAuth2Service.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class OAuth2Service {
    // MARK: - Lifecycle

    init(
        apiResourceServer: ApiResourceServer
    ) {
        self.apiResourceServer = apiResourceServer
    }

    // MARK: - Internal

    func performResourceOwnerPasswordCredentialsGrant(
        with credential: PasswordCredential
    ) async throws -> OAuth2Token {
        // Implementation
        throw NSError(domain: "", code: 0, userInfo: nil)
    }

    // MARK: - Private

    private let apiResourceServer: ApiResourceServer

    private func performGrant(
    ) async {
//        apiResourceServer.performPublicApiKeyAuthenticationRequest(forTenant: <#T##String#>, applicationId: <#T##String#>, apiKeyId: <#T##String#>, userId: <#T##String#>)
    }
}

extension OAuth2Service {
    struct PasswordCredential: Codable {
        let username: String
        let password: String
    }

    struct OAuth2Token: Codable {
        let accessToken: String
        let scope: String
        let tokenType: String
        let expiresIn: TimeInterval
        let refreshToken: String
    }
}
