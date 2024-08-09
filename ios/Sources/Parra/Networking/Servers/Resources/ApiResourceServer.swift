//
//  ApiResourceServer.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

private let logger = Logger(category: "ApiResourceServer")

typealias NetworkCompletionHandler<T> = (Result<T, ParraError>) -> Void

@MainActor
final class ApiResourceServer: Server {
    // MARK: - Lifecycle

    init(
        authService: AuthService,
        appState: ParraAppState,
        appConfig: ParraConfiguration,
        dataManager: DataManager,
        configuration: ServerConfiguration
    ) {
        self.authService = authService
        self.appState = appState
        self.appConfig = appConfig
        self.configuration = configuration
    }

    // MARK: - Internal

    weak var delegate: ServerDelegate?
    let authService: AuthService
    let appState: ParraAppState
    let appConfig: ParraConfiguration

    let configuration: ServerConfiguration

    lazy var urlSessionDelegateProxy: UrlSessionDelegateProxy =
        .init(
            delegate: self
        )

    func hitApiEndpoint<T: Decodable>(
        endpoint: ApiEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeout: TimeInterval? = nil
    ) async -> AuthenticatedRequestResult<T> {
        return await hitApiEndpoint(
            endpoint: endpoint,
            queryItems: queryItems,
            config: config,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject(),
            timeout: timeout
        )
    }

    func hitApiEndpoint<T: Decodable>(
        endpoint: ApiEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable,
        timeout: TimeInterval? = nil
    ) async -> AuthenticatedRequestResult<T> {
        logger
            .trace(
                "Performing request to API endpoint: \(endpoint.slugWithMethod)"
            )

        do {
            let body = try configuration.jsonEncoder.encode(body)
            var initialRequest = try createRequest(
                to: endpoint,
                queryItems: queryItems,
                config: config,
                cachePolicy: cachePolicy,
                body: body
            )

            let accessToken = try await authService
                .getAccessTokenRefreshingIfNeeded()

            initialRequest.setValue(
                for: .authorization(.bearer(accessToken))
            )

            let (
                result,
                responseContext
            ) = await performReauthenticatingRequest(
                request: initialRequest,
                config: config
            ) { request in
                return try await self.performAsyncDataTask(
                    request: request
                )
            }

            switch result {
            case .success(let data):
                logger.trace("Parra client received success response")

                let response = try decodeResponse(
                    from: data,
                    as: T.self
                )

                return AuthenticatedRequestResult(
                    result: .success(response),
                    responseContext: responseContext
                )
            case .failure(let error):
                throw error
            }
        } catch {
            return AuthenticatedRequestResult(
                result: .failure(error),
                responseContext: AuthenticatedRequestResponseContext(
                    attributes: [],
                    statusCode: nil
                )
            )
        }
    }

    func hitUploadEndpoint<T: Decodable>(
        endpoint: ApiEndpoint,
        formFields: [MultipartFormField],
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeout: TimeInterval? = nil
    ) async -> AuthenticatedRequestResult<T> {
        logger
            .trace(
                "Performing upload to API endpoint: \(endpoint.slugWithMethod)"
            )

        do {
            var initialRequest = try createRequest(
                to: endpoint,
                queryItems: queryItems,
                config: config,
                cachePolicy: cachePolicy,
                timeout: timeout
            )

            let accessToken = try await authService
                .getAccessTokenRefreshingIfNeeded()

            initialRequest.setValue(
                for: .authorization(.bearer(accessToken))
            )

            let (
                result,
                responseContext
            ) = await performReauthenticatingRequest(
                request: initialRequest,
                config: .default
            ) { request in
                return try await performAsyncMultipartUploadTask(
                    request: request,
                    formFields: formFields
                )
            }

            switch result {
            case .success(let data):
                logger.trace("Parra client received success response")

                let response = try decodeResponse(
                    from: data,
                    as: T.self
                )

                return AuthenticatedRequestResult(
                    result: .success(response),
                    responseContext: responseContext
                )
            case .failure(let error):
                throw error
            }
        } catch {
            return AuthenticatedRequestResult(
                result: .failure(error),
                responseContext: AuthenticatedRequestResponseContext(
                    attributes: [],
                    statusCode: nil
                )
            )
        }
    }

    // MARK: - Private

    // Perform request wrapper that automatically handles reauthentication and
    // retrying if the request fails unauthenticated/unauthorized.
    private func performReauthenticatingRequest(
        request: URLRequest,
        config: RequestConfig = .default,
        using resolver: (URLRequest) async throws -> (Data, HTTPURLResponse)
    ) async -> (Result<Data, Error>, AuthenticatedRequestResponseContext) {
        do {
            let (
                data,
                response
            ) = try await resolver(request)

            logger.trace(
                "Parra client received response. Status: \(response.statusCode)"
            )

            switch (response.statusCode, config.shouldReauthenticate) {
            case (204, _):
                return (
                    .success(EmptyJsonObjectData),
                    AuthenticatedRequestResponseContext(
                        attributes: config.attributes,
                        statusCode: response.statusCode
                    )
                )
            // If unauthenticated, we need to refresh the auth token and try
            // again to obtain a credential. If unauthorized, we want to do
            // the same to purge a potentially invalid token and replace it
            // with a new one.
            case (401, true), (403, true):
                logger.trace("Request required reauthentication")

                var nextRequest = request

                // The cached token clearly isn't valid, so force a refresh
                // before retrying the request.
                let newToken = try await authService.getRefreshedToken()

                nextRequest.setValue(
                    for: .authorization(.bearer(newToken))
                )

                return await performReauthenticatingRequest(
                    request: nextRequest,
                    config: config
                        .withoutReauthenticating()
                        .withAttribute(.requiredReauthentication),
                    using: resolver
                )
            case (401, false):
                let message =
                    "Failed to authenticate with the Parra API after a retry. The token returned by your authentication provider is likely invalid. Please check your authentication provider and try again."

                return (
                    .failure(
                        ParraError.authenticationFailed(message)
                    ),
                    AuthenticatedRequestResponseContext(
                        attributes: config.attributes,
                        statusCode: response.statusCode
                    )
                )
            case (400 ... 499, _):
                return (
                    .failure(
                        ParraError.networkError(
                            request: request,
                            response: response,
                            responseData: data
                        )
                    ),
                    AuthenticatedRequestResponseContext(
                        attributes: config.attributes,
                        statusCode: response.statusCode
                    )
                )
            case (500 ... 599, _):
                if config.shouldRetry {
                    logger.trace("Retrying previous request")

                    let nextConfig = config
                        .afterRetrying()
                        .withAttribute(.requiredRetry)

                    try await Task.sleep(for: nextConfig.retryDelay)

                    return await performReauthenticatingRequest(
                        request: request,
                        config: nextConfig,
                        using: resolver
                    )
                }

                var attributes = config.attributes
                if attributes.contains(.requiredRetry) {
                    attributes.insert(.exceededRetryLimit)
                }

                return (
                    .failure(ParraError.networkError(
                        request: request,
                        response: response,
                        responseData: data
                    )),
                    AuthenticatedRequestResponseContext(
                        attributes: attributes,
                        statusCode: response.statusCode
                    )
                )
            default:
                return (
                    .success(data),
                    AuthenticatedRequestResponseContext(
                        attributes: config.attributes,
                        statusCode: response.statusCode
                    )
                )
            }
        } catch {
            return (
                .failure(error),
                AuthenticatedRequestResponseContext(
                    attributes: config.attributes,
                    statusCode: nil
                )
            )
        }
    }
}
