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
        configuration: ServerConfiguration,
        dataManager: DataManager
    ) {
        self.appState = appState
        self.appConfig = appConfig
        self.configuration = configuration
        self.dataManager = dataManager
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
    let dataManager: DataManager
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

        return try await performOptionalAuthRequest(
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
        return try await performOptionalAuthRequest(
            to: .postLogin(
                tenantId: appState.tenantId
            ),
            with: accessToken
        )
    }

    func postLogout(
        accessToken: String
    ) async throws {
        let _: EmptyResponseObject = try await performOptionalAuthRequest(
            to: .postLogout(
                tenantId: appState.tenantId
            ),
            with: accessToken
        )
    }

    func postAuthChallenges(
        requestData: AuthChallengesRequestBody
    ) async throws -> AuthChallengeResponse {
        let body = try configuration.jsonEncoder.encode(requestData)

        return try await performOptionalAuthRequest(
            to: .postAuthChallenges(
                tenantId: appState.tenantId
            ),
            with: nil,
            body: body
        )
    }

    func postPasswordless(
        requestData: PasswordlessChallengeRequestBody
    ) async throws -> ParraPasswordlessChallengeResponse {
        let body = try configuration.jsonEncoder.encode(requestData)

        return try await performOptionalAuthRequest(
            to: .postPasswordless(
                tenantId: appState.tenantId
            ),
            with: nil,
            body: body
        )
    }

    func postWebAuthnRegisterChallenge(
        requestData: WebAuthnRegisterChallengeRequest
    ) async throws -> PublicKeyCredentialCreationOptions {
        let data: [String: String] = [
            "username": requestData.username
        ]

        return try await performOptionalAuthFormEncodedRequest(
            to: .postWebAuthnRegisterChallenge(
                tenantId: appState.tenantId
            ),
            with: nil,
            data: data
        )
    }

    func postWebAuthnAuthenticateChallenge(
        requestData: WebAuthnAuthenticateChallengeRequest
    ) async throws -> PublicKeyCredentialRequestOptions {
        var data: [String: String] = [:]
        if let username = requestData.username {
            data["username"] = username
        }

        return try await performOptionalAuthFormEncodedRequest(
            to: .postWebAuthnAuthenticateChallenge(
                tenantId: appState.tenantId
            ),
            with: nil,
            data: data
        )
    }

    func getUserInfo(
        accessToken: String,
        timeout: TimeInterval? = nil
    ) async throws -> UserInfoResponse {
        return try await performOptionalAuthRequest(
            to: .getUserInfo(
                tenantId: appState.tenantId
            ),
            with: accessToken,
            timeout: timeout
        )
    }

    func getAppInfo(
        versionToken: String?,
        timeout: TimeInterval? = nil
    ) async throws -> ParraAppInfo {
        var queryItems = [String: String]()

        if let versionToken {
            // If nil, key not be set.
            queryItems["version_token"] = versionToken
        }

        // nil if un-authenticated but if the token is expired, we need to not
        // send it to treat this as an unauthenticated request. It's important
        // that fetching app into happens quickly and doesn't block the user.
        let credential = await dataManager.getCurrentCredential()

        let accessToken: String? = switch credential {
        case .basic(let token):
            token
        case .oauth2(let token):
            if token.isExpired || token.isNearlyExpired {
                {
                    logger.debug(
                        "Access token has expired. Skipping sending with get app info request"
                    )

                    return nil
                }()
            } else {
                token.accessToken
            }
        case nil:
            nil
        }

        return try await performOptionalAuthRequest(
            to: .getAppInfo(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            ),
            with: accessToken,
            queryItems: queryItems,
            timeout: timeout
        )
    }

    // MARK: - Private

    private func performOptionalAuthRequest<T>(
        to endpoint: ParraEndpoint,
        with accessToken: String?,
        queryItems: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        guard var urlComponents = URLComponents(
            url: endpoint.url,
            resolvingAgainstBaseURL: false
        ) else {
            throw ParraError.generic(
                "Failed to create components for url: \(endpoint.url)",
                nil
            )
        }

        urlComponents.setQueryItems(with: queryItems)

        var request = URLRequest(url: urlComponents.url!)

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

    private func performOptionalAuthFormEncodedRequest<T>(
        to endpoint: ParraEndpoint,
        with accessToken: String?,
        data: [String: String],
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        return try await performFormPostRequest(
            to: endpoint.url,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
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
