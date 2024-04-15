//
//  AuthServer.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

/// Intentionally separated from ``ApiResourceServer`` to avoid any of the auto
/// inclusion of headers/etc from interferring with authentication standards.
final class AuthServer: Server {
    // MARK: - Lifecycle

    init(
        configuration: ServerConfiguration
    ) {
        self.configuration = configuration
    }

    // MARK: - Internal

    let configuration: ServerConfiguration

    func performPublicApiKeyAuthenticationRequest(
        forTenant tenantId: String,
        apiKeyId: String,
        userId: String
    ) async throws -> String {
        let endpoint = ParraEndpoint.postAuthentication(tenantId: tenantId)
        let url = ParraInternal.Constants.parraApiRoot
            .appendingPathComponent(endpoint.route)

        var request = URLRequest(url: url)

        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try configuration.jsonEncoder
            .encode(["user_id": userId])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        guard let authToken = ("api_key:" + apiKeyId).data(
            using: .utf8
        )?.base64EncodedString() else {
            throw ParraError.generic("Unable to encode API key as NSData", nil)
        }

        request.setValue(for: .authorization(.basic(authToken)))

        let (data, response) = try await performAsyncDataTask(
            request: request
        )

        switch response.statusCode {
        case 200:
            let credential = try configuration.jsonDecoder.decode(
                ParraCredential.self,
                from: data
            )

            return credential.token
        default:
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }
    }
}
