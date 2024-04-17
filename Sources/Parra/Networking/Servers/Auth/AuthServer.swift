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
        appState: ParraAppState,
        configuration: ServerConfiguration
    ) {
        self.appState = appState
        self.configuration = configuration
    }

    // MARK: - Internal

    struct PublicAuthResponse: Codable {
        let accessToken: String
    }

    let appState: ParraAppState
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
                PublicAuthResponse.self,
                from: data
            )

            return credential.accessToken
        default:
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }
    }

    func getUserInformation(
        token: String
    ) async throws -> ParraUser.Info {
        let endpoint = ParraEndpoint.getUserInfo
        let url = ParraInternal.Constants.parraApiRoot
            .appendingPathComponent(endpoint.route)

        var request = URLRequest(url: url)

        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = .reloadRevalidatingCacheData
        request.setValue(for: .authorization(.bearer(token)))

        let (data, response) = try await performAsyncDataTask(
            request: request
        )

        // TODO: Response object will be something with tenant_user key
        return ParraUser.Info()
//        switch response.statusCode {
//        case 200:
//            return try configuration.jsonDecoder.decode(
//                ParraUser.Info.self,
//                from: data
//            )
//        default:
//            throw ParraError.networkError(
//                request: request,
//                response: response,
//                responseData: data
//            )
//        }
    }
}
