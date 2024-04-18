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

    func performRequest<T: Decodable>(
        endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async -> AuthenticatedRequestResult<T> {
        return await performRequest(
            endpoint: endpoint,
            queryItems: queryItems,
            config: config,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }

    func performRequest<T: Decodable>(
        endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable
    ) async -> AuthenticatedRequestResult<T> {
        let route = endpoint.route
        let method = endpoint.method

        logger
            .trace(
                "Performing authenticated request to route: \(method.rawValue) \(route)"
            )

        do {
            let headerFactory = HeaderFactory(
                appState: appState,
                appConfig: appConfig
            )

            let url = ParraInternal.Constants.parraApiRoot
                .appendingPathComponent(route)
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
            let user = await authService.getCurrentUser()

            let token: String = if let user {
                user.credential.accessToken
            } else {
                try await authService.refreshExistingToken()
            }

            var request = URLRequest(
                url: urlComponents.url!,
                cachePolicy: cachePolicy ?? .useProtocolCachePolicy
            )

            request.httpMethod = method.rawValue
            if method.allowsBody {
                request.httpBody = try configuration.jsonEncoder.encode(body)
            }

            addHeaders(
                to: &request,
                endpoint: endpoint,
                for: appState,
                with: headerFactory
            )

            let (result, responseContext) = await performRequest(
                request: request,
                with: token,
                config: config
            )

            switch result {
            case .success(let data):
                logger.trace("Parra client received success response")

                let response = try configuration.jsonDecoder.decode(
                    T.self,
                    from: data
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

    /// URLs not controlled by Parra/external APIs/etc.
    func performExternalRequest<T: Decodable>(
        to url: URL,
        method: HttpMethod = .get,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async throws -> T {
        return try await performExternalRequest(
            to: url,
            method: method,
            queryItems: queryItems,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }

    /// URLs not controlled by Parra/external APIs/etc.
    func performExternalRequest<T: Decodable>(
        to url: URL,
        method: HttpMethod = .get,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable
    ) async throws -> T {
        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy
        )

        request.httpMethod = method.rawValue
        if method.allowsBody {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, _) = try await performAsyncDataTask(request: request)

        return try JSONDecoder().decode(
            T.self,
            from: data
        )
    }

    func performBulkAssetCachingRequest(assets: [Asset]) async {
        logger
            .trace(
                "Performing bulk asset caching request for \(assets.count) asset(s)"
            )
        let _ = await assets.asyncMap { asset in
            return try? await fetchAsset(asset: asset)
        }
    }

    func fetchAsset(asset: Asset) async throws -> UIImage? {
        logger.trace("Fetching asset: \(asset.id)", [
            "url": asset.url
        ])

        let request = request(for: asset)

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: nil
            )
        let httpResponse = response as! HTTPURLResponse

        defer {
            logger.trace("Caching asset: \(asset.id)")

            let cacheResponse = CachedURLResponse(
                response: response,
                data: data,
                storagePolicy: .allowed
            )

            configuration.urlSession.configuration.urlCache?
                .storeCachedResponse(
                    cacheResponse,
                    for: request
                )
        }

        if httpResponse.statusCode < 300 {
            logger.trace("Successfully retreived image for asset: \(asset.id)")

            return UIImage(data: data)
        }

        logger.warn("Failed to download image for asset: \(asset.id)")

        return nil
    }

    func isAssetCached(asset: Asset) -> Bool {
        logger.trace("Checking if asset is cached: \(asset.id)")

        guard let cache = configuration.urlSession.configuration.urlCache else {
            logger.trace("Cache is missing")

            return false
        }

        guard let cachedResponse = cache
            .cachedResponse(for: request(for: asset)) else
        {
            logger.trace("Cache miss for asset: \(asset.id)")
            return false
        }

        guard cachedResponse.storagePolicy != .notAllowed else {
            logger.trace("Storage policy disallowed for asset: \(asset.id)")

            return false
        }

        logger.trace("Cache hit for asset: \(asset.id)")

        return true
    }

    // MARK: - Private

    private lazy var urlSessionDelegateProxy: UrlSessionDelegateProxy =
        .init(
            delegate: self
        )

    private func performRequest(
        request: URLRequest,
        with token: String,
        config: RequestConfig = .default
    ) async -> (Result<Data, Error>, AuthenticatedRequestResponseContext) {
        do {
            var request = request
            request.setValue(for: .authorization(.bearer(token)))

            let (
                data,
                response
            ) = try await performAsyncDataTask(request: request)

            logger
                .trace(
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
            // again to obtain a credential. If unauthorized, we want to do the
            // same to purge a potentially invalid token and replace it with a
            // new one.
            case (401, true), (403, true):
                logger.trace("Request required reauthentication")

                let newToken = try await authService.refreshExistingToken()

                request
                    .setValue(for: .authorization(.bearer(newToken)))

                return await performRequest(
                    request: request,
                    with: token,
                    config: config
                        .withoutReauthenticating()
                        .withAttribute(.requiredReauthentication)
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

                    return await performRequest(
                        request: request,
                        with: token,
                        config: nextConfig
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

    private func request(for asset: Asset) -> URLRequest {
        var request = URLRequest(
            url: asset.url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 10.0
        )
        request.httpMethod = HttpMethod.get.rawValue

        return request
    }

    private func performAsyncDataTask(request: URLRequest) async throws
        -> (Data, HTTPURLResponse)
    {
        #if DEBUG
        // There is a different delay added in the UrlSession mocks that
        // slows down tests. This delay is specific to helping prevent us
        // from introducing UI without proper loading states.
        if NSClassFromString("XCTestCase") == nil {
            try await Task.sleep(for: 1.0)
        }
        #endif

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: urlSessionDelegateProxy
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            // It is documented that for data tasks, response is always actually
            // HTTPURLResponse, so this should never happen.
            throw ParraError
                .message(
                    "Unexpected networking error. HTTP response was unexpected class"
                )
        }

        delegate?.server(
            self,
            didReceiveResponse: httpResponse,
            for: request
        )

        return (data, httpResponse)
    }
}
