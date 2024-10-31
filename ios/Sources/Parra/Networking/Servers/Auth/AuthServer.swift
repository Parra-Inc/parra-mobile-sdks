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
@MainActor
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
        let endpoint = IssuerEndpoint.postPublicAuthentication
        let appInfo = try await getAppInfo()
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            tenant: appInfo.tenant
        )

        var request = try URLRequest(
            with: [:],
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )

        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try configuration.jsonEncoder
            .encode(["user_id": userId])
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

    ///   - anonymousToken: If the user was previously logged in as an anonymous
    ///   or guest user, pass their refresh token so the identities can be
    ///   associated.
    func postLogin(
        accessToken: String,
        anonymousToken: String?
    ) async throws -> UserInfoResponse {
        let requestData = LoginUserRequestBody(
            anonymousToken: anonymousToken
        )

        let body = try configuration.jsonEncoder.encode(requestData)

        return try await performOptionalAuthRequest(
            to: .postLogin,
            with: accessToken,
            body: body,
            allowedRetries: 1
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
            cachePolicy: .reloadRevalidatingCacheData,
            allowedRetries: 2
        )
    }

    func authenticateWithoutAccount(
        endpoint: IssuerEndpoint,
        authType: OAuth2Service.AuthType
    ) async throws -> OAuth2Service.TokenResponse {
        let data: [String: String] = switch authType {
        case .anonymous(let refreshToken), .guest(let refreshToken):
            if let refreshToken {
                ["token": refreshToken]
            } else {
                [:]
            }
        default:
            [:]
        }

        let body = try JSONEncoder.parraWebauthEncoder.encode(data)

        let (response, _): (
            OAuth2Service.TokenResponse,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: endpoint,
            with: nil,
            body: body
        )

        return response
    }

    func refreshWithoutAccount(
        endpoint: IssuerEndpoint,
        authType: OAuth2Service.AuthType
    ) async throws -> OAuth2Service.RefreshResponse {
        let data: [String: String] = switch authType {
        case .anonymous(let refreshToken), .guest(let refreshToken):
            if let refreshToken {
                ["token": refreshToken]
            } else {
                [:]
            }
        default:
            [:]
        }

        let body = try JSONEncoder.parraWebauthEncoder.encode(data)

        let (response, _): (
            OAuth2Service.RefreshResponse,
            HTTPURLResponse
        ) = try await performUnauthenticatedRequest(
            to: endpoint,
            with: nil,
            body: body
        )

        return response
    }

    // MARK: - Private

    private func getAppInfo() async throws -> ParraAppInfo {
        return try await Parra.default.parraInternal.appInfoManager.getAppInfo()
    }

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
        config: RequestConfig = .defaultWithRetries,
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        cachePolicy: NSURLRequest
            .CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        allowedRetries: Int
    ) async throws -> T where T: Codable {
        var request = try await createRequest(
            to: endpoint,
            queryItems: queryItems,
            config: config,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            body: body,
            timeout: timeout ?? configuration.urlSession
                .configuration.timeoutIntervalForRequest
        )

        addHeaders(
            to: &request,
            endpoint: endpoint,
            for: appState,
            with: headerFactory
        )

        if let accessToken {
            request.setValue(for: .authorization(.bearer(accessToken)))
        }

        let (data, _): (T, HTTPURLResponse) = try await performRequest(
            request: request,
            allowedRetries: allowedRetries
        )

        return data
    }

    private func performUnauthenticatedRequest<T>(
        to endpoint: IssuerEndpoint,
        with accessToken: String?,
        queryItems: [String: String] = [:],
        extraHeaders: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval? = nil,
        allowedRetries: Int = 0
    ) async throws -> (T, HTTPURLResponse) where T: Codable {
        let appInfo = try await getAppInfo()
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            tenant: appInfo.tenant
        )

        var request = try URLRequest(
            with: queryItems,
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )

        request.httpMethod = endpoint.method.rawValue
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
            request: request,
            allowedRetries: allowedRetries
        )
    }

    private func performOptionalAuthFormEncodedRequest<T>(
        to endpoint: IssuerEndpoint,
        with accessToken: String?,
        data: [String: String],
        timeout: TimeInterval? = nil
    ) async throws -> T where T: Codable {
        let appInfo = try await getAppInfo()
        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            tenant: appInfo.tenant
        )

        return try await performFormPostRequest(
            to: url,
            data: data,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeout: timeout
        )
    }

    private func performRequest<T>(
        request: URLRequest,
        allowedRetries: Int
    ) async throws -> (T, HTTPURLResponse) where T: Codable {
        do {
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
                if allowedRetries > 0 {
                    logger.warn(
                        "Request required retry",
                        [
                            "url": request.url?.absoluteString ?? "unknown",
                            "method": request.httpMethod ?? "unknown",
                            "statusCode": response.statusCode,
                            "remainingRetries": allowedRetries
                        ]
                    )

                    return try await performRequest(
                        request: request,
                        allowedRetries: allowedRetries - 1
                    )
                }

                throw ParraError.networkError(
                    request: request,
                    response: response,
                    responseData: data
                )
            }
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                if allowedRetries > 0 {
                    logger.warn(
                        "Request required retry due to timeout",
                        [
                            "url": request.url?.absoluteString ?? "unknown",
                            "method": request.httpMethod ?? "unknown",
                            "remainingRetries": allowedRetries
                        ]
                    )

                    return try await performRequest(
                        request: request,
                        allowedRetries: allowedRetries - 1
                    )
                }

                throw urlError
            default:
                throw urlError
            }
        } catch {
            throw error
        }
    }
}
