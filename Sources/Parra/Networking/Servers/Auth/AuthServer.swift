//
//  AuthServer.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

/// Intentionally separated from ``ApiResourceServer`` to avoid any of the auto
/// inclusion of headers/etc from interferring with authentication standards.
final class AuthServer: Server {
    // MARK: - Lifecycle

    init(
        appState: ParraAppState,
        appConfig: ParraConfiguration,
        configuration: ServerConfiguration
    ) {
        self.appState = appState
        self.appConfig = appConfig
        self.configuration = configuration
        self.headerFactory = HeaderFactory(
            appState: appState,
            appConfig: appConfig
        )
    }

    // MARK: - Internal

    struct PublicAuthResponse: Codable {
        let accessToken: String
    }

    let appState: ParraAppState
    let appConfig: ParraConfiguration
    let configuration: ServerConfiguration
    let headerFactory: HeaderFactory
    weak var delegate: ServerDelegate?

    func performPublicApiKeyAuthenticationRequest(
        apiKeyId: String,
        userId: String,
        timeout: TimeInterval? = nil
    ) async throws -> String {
        let endpoint = ParraEndpoint.postAuthentication(
            tenantId: appState.tenantId
        )

        var request = URLRequest(url: endpoint.url)

        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try configuration.jsonEncoder
            .encode(["user_id": userId])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = timeout ?? configuration.urlSession
            .configuration.timeoutIntervalForRequest

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

    @discardableResult
    func postSignup(
        requestData: CreateUserRequestBody
    ) async throws -> User {
        let body = try configuration.jsonEncoder.encode(requestData)

        return try await performAuthRequest(
            to: .postCreateUser(
                tenantId: appState.tenantId
            ),
            with: nil,
            body: body
        )
    }

    func postLogin(
        accessToken: String
    ) async throws -> UserInfoResponse {
        return try await performAuthRequest(
            to: .postLogin(
                tenantId: appState.tenantId
            ),
            with: accessToken
        )
    }

    func postLogout(
        accessToken: String
    ) async throws {
        let _: EmptyResponseObject = try await performAuthRequest(
            to: .postLogout(
                tenantId: appState.tenantId
            ),
            with: accessToken
        )
    }

    func getUserInfo(
        accessToken: String,
        timeout: TimeInterval? = nil
    ) async throws -> UserInfoResponse {
        return try await performAuthRequest(
            to: .getUserInfo(
                tenantId: appState.tenantId
            ),
            with: accessToken,
            timeout: timeout
        )
    }

    // MARK: - Private

    private func performAuthRequest<T>(
        to endpoint: ParraEndpoint,
        with accessToken: String?,
        body: Data? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        var request = URLRequest(url: endpoint.url)

        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = timeout ?? configuration.urlSession
            .configuration.timeoutIntervalForRequest

        if let accessToken {
            request.setValue(for: .authorization(.bearer(accessToken)))
        }

        if let body {
            request.httpBody = body
        }

        addHeaders(
            to: &request,
            endpoint: endpoint,
            for: appState,
            with: headerFactory
        )

        return try await performRequest(
            request: request,
            timeout: timeout
        )
    }

    private func performRequest<T>(
        request: URLRequest,
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        let (data, response) = try await performAsyncDataTask(
            request: request
        )

        switch response.statusCode {
        case 204:
            return try configuration.jsonDecoder.decode(
                T.self,
                from: EmptyJsonObjectData
            )
        case 200 ..< 300:
            return try configuration.jsonDecoder.decode(
                T.self,
                from: data
            )
        default:
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }
    }
}
