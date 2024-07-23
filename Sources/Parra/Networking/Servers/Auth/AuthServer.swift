//
//  AuthServer.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

private let parraWebauthnSessionHeader = "PARRA-WEBAUTHN-SESSION"

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

    lazy var urlSessionDelegateProxy: UrlSessionDelegateProxy =
        .init(
            delegate: self
        )

    func performPublicApiKeyAuthenticationRequest(
        apiKeyId: String,
        userId: String,
        timeout: TimeInterval? = nil
    ) async throws -> String {
        let endpoint = IssuerEndpoint.postAuthentication
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            using: appState
        )

        var request = URLRequest(url: url)

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
            let credential = try decodeResponse(
                from: data,
                as: PublicAuthResponse.self
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
    ) async throws -> ParraUser.Info {
        let body = try configuration.jsonEncoder.encode(requestData)

        let (data, _): (
            ParraUser.Info,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postCreateUser,
            with: nil,
            body: body
        )

        return data
    }

    func postLogin(
        accessToken: String
    ) async throws -> UserInfoResponse {
        return try await performOptionalAuthRequest(
            to: .postLogin,
            with: accessToken
        )
    }

    func postForgotPassword(
        requestData: PasswordResetChallengeRequestBody
    ) async throws -> HTTPURLResponse {
        let body = try configuration.jsonEncoder.encode(requestData)

        let (_, response): (
            EmptyResponseObject,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postForgotPassword,
            with: nil,
            body: body
        )

        return response
    }

    func postResetPassword(
        requestData: PasswordResetRequestBody
    ) async throws {
        let body = try configuration.jsonEncoder.encode(requestData)

        let (_, _): (
            EmptyResponseObject,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postResetPassword,
            with: nil,
            body: body
        )
    }

    func postLogout(
        accessToken: String
    ) async throws {
        let _: EmptyResponseObject = try await performOptionalAuthRequest(
            to: .postLogout,
            with: accessToken
        )
    }

    func postAuthChallenges(
        requestData: AuthChallengesRequestBody
    ) async throws -> AuthChallengeResponse {
        let body = try configuration.jsonEncoder.encode(requestData)

        let (data, _): (
            AuthChallengeResponse,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postAuthChallenges,
            with: nil,
            body: body
        )

        return data
    }

    func postPasswordless(
        requestData: PasswordlessChallengeRequestBody
    ) async throws -> ParraPasswordlessChallengeResponse {
        let body = try configuration.jsonEncoder.encode(requestData)

        let (data, _): (
            ParraPasswordlessChallengeResponse,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postPasswordless,
            with: nil,
            body: body
        )

        return data
    }

    func postWebAuthnRegisterChallenge(
        requestData: WebAuthnRegisterChallengeRequest
    ) async throws -> (PublicKeyCredentialCreationOptions, String) {
        let body = try JSONEncoder.parraWebauthEncoder.encode(requestData)

        let (data, response): (
            PublicKeyCredentialCreationOptions,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postWebAuthnRegisterChallenge,
            with: nil,
            body: body
        )

        return try (data, webauthnSessionHeader(from: response))
    }

    func postWebAuthnAuthenticateChallenge(
        requestData: WebAuthnAuthenticateChallengeRequest
    ) async throws -> (PublicKeyCredentialRequestOptions, String) {
        let body = try JSONEncoder.parraWebauthEncoder.encode(requestData)

        let (data, response): (
            PublicKeyCredentialRequestOptions,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postWebAuthnAuthenticateChallenge,
            with: nil,
            body: body
        )

        return try (data, webauthnSessionHeader(from: response))
    }

    func postWebAuthnRegister(
        requestData: WebauthnRegisterRequestBody,
        session: String
    ) async throws -> WebauthnRegisterResponseBody {
        let body = try JSONEncoder.parraWebauthEncoder.encode(requestData)

        let (data, _): (
            WebauthnRegisterResponseBody,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postWebAuthnRegister,
            with: nil,
            extraHeaders: [
                parraWebauthnSessionHeader: session
            ],
            body: body
        )

        return data
    }

    func postWebAuthnAuthenticate(
        requestData: WebauthnAuthenticateRequestBody,
        session: String
    ) async throws -> WebauthnAuthenticateResponseBody {
        let body = try JSONEncoder.parraWebauthEncoder.encode(requestData)

        let (data, _): (
            WebauthnAuthenticateResponseBody,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: .postWebAuthnAuthenticate,
            with: nil,
            extraHeaders: [
                parraWebauthnSessionHeader: session
            ],
            body: body
        )

        return data
    }

    func getUserInfo(
        accessToken: String,
        timeout: TimeInterval? = nil
    ) async throws -> UserInfoResponse {
        return try await performOptionalAuthRequest(
            to: .getUserInfo,
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
            to: .getAppInfo,
            with: accessToken,
            queryItems: queryItems,
            timeout: timeout,
            cachePolicy: .reloadRevalidatingCacheData
        )
    }

    // MARK: - Private

    private func webauthnSessionHeader(
        from response: HTTPURLResponse
    ) throws -> String {
        guard let value = response.value(
            forHTTPHeaderField: parraWebauthnSessionHeader
        ) else {
            throw ParraError
                .message(
                    "Missing expected \(parraWebauthnSessionHeader) header"
                )
        }

        return value
    }

    private func performOptionalAuthRequest<T>(
        to endpoint: ApiEndpoint,
        with accessToken: String?,
        queryItems: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        cachePolicy: NSURLRequest
            .CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    ) async throws -> T where T: Codable {
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            using: appState
        )

        guard var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            throw ParraError.generic(
                "Failed to create components for url: \(url)",
                nil
            )
        }

        urlComponents.setQueryItems(with: queryItems)

        var request = URLRequest(url: urlComponents.url!)

        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = cachePolicy
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

        let (data, _): (T, HTTPURLResponse) = try await performRequest(
            request: request
        )

        return data
    }

    private func performUnauthenticatedRequest<T>(
        to endpoint: IssuerEndpoint,
        with accessToken: String?,
        queryItems: [String: String] = [:],
        extraHeaders: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> (T, HTTPURLResponse) where T: Codable {
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            using: appState
        )

        guard var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            throw ParraError.generic(
                "Failed to create components for url: \(url)",
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

        if !extraHeaders.isEmpty {
            for (key, value) in extraHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return try await performRequest(
            request: request
        )
    }

    private func performOptionalAuthFormEncodedRequest<T>(
        to endpoint: IssuerEndpoint,
        with accessToken: String?,
        data: [String: String],
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            using: appState
        )

        return try await performFormPostRequest(
            to: url,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeout: timeout
        )
    }

    private func performRequest<T>(
        request: URLRequest
    ) async throws -> (T, HTTPURLResponse) where T: Codable {
        let (data, response) = try await performAsyncDataTask(
            request: request
        )

        switch response.statusCode {
        case 202, 204:
            let body = try decodeResponse(
                from: EmptyJsonObjectData,
                as: T.self
            )

            return (body, response)
        case 200 ..< 300:
            let body = try decodeResponse(
                from: data,
                as: T.self
            )

            return (body, response)
        default:
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }
    }
}
