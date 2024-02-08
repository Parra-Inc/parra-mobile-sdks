//
//  ParraNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

private let logger = Logger(category: "Network Manager")

typealias NetworkCompletionHandler<T> = (Result<T, ParraError>) -> Void

actor ParraNetworkManager: NetworkManagerType, ParraModuleStateAccessor {
    // MARK: Lifecycle

    init(
        state: ParraState,
        dataManager: ParraDataManager,
        urlSession: URLSessionType,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.state = state
        self.dataManager = dataManager
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    // MARK: Internal

    let state: ParraState

    func getAuthenticationProvider() async
        -> ParraAuthenticationProviderFunction?
    {
        return authenticationProvider
    }

    func updateAuthenticationProvider(
        _ provider: ParraAuthenticationProviderFunction?
    ) {
        authenticationProvider = provider
    }

    func refreshAuthentication() async throws -> ParraCredential {
        return try await logger.withScope { logger in
            logger.debug("Performing reauthentication for Parra")

            guard let authenticationProvider else {
                throw ParraError.missingAuthentication
            }

            do {
                logger.info("Invoking Parra authentication provider")

                let token = try await authenticationProvider()
                let credential = ParraCredential(token: token)

                await dataManager.updateCredential(
                    credential: credential
                )

                logger.info("Reauthentication with Parra succeeded")

                return credential
            } catch {
                let framing =
                    "╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍"
                logger
                    .error(
                        "\n\(framing)\n\nReauthentication with Parra failed.\nInvoking the authProvider passed to Parra.initialize failed with error: \(error.localizedDescription)\n\n\(framing)"
                    )
                throw ParraError
                    .authenticationFailed(error.localizedDescription)
            }
        }
    }

    func performAuthenticatedRequest<T: Decodable>(
        endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) async -> AuthenticatedRequestResult<T> {
        return await performAuthenticatedRequest(
            endpoint: endpoint,
            queryItems: queryItems,
            config: config,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }

    func performAuthenticatedRequest<T: Decodable>(
        endpoint: ParraEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable
    ) async -> AuthenticatedRequestResult<T> {
        let route = endpoint.route
        let method = endpoint.method

        var responseAttributes: AuthenticatedRequestAttributeOptions = []

        logger
            .trace(
                "Performing authenticated request to route: \(method.rawValue) \(route)"
            )

        do {
            guard let applicationId = await state.applicationId else {
                throw ParraError.notInitialized
            }

            let url = Parra.InternalConstants.parraApiRoot
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
            let credential = await dataManager.getCurrentCredential()

            let nextCredential: ParraCredential = if let credential {
                credential
            } else {
                try await refreshAuthentication()
            }

            var request = URLRequest(
                url: urlComponents.url!,
                cachePolicy: cachePolicy ?? .useProtocolCachePolicy
            )

            request.httpMethod = method.rawValue
            if method.allowsBody {
                request.httpBody = try jsonEncoder.encode(body)
            }
            addHeaders(to: &request, endpoint: endpoint, for: applicationId)

            let (result, attributes) = await performRequest(
                request: request,
                credential: nextCredential,
                config: config
            )

            responseAttributes.insert(attributes)

            switch result {
            case .success(let data):
                logger.trace("Parra client received success response")

                let response = try jsonDecoder.decode(T.self, from: data)

                return AuthenticatedRequestResult(
                    result: .success(response),
                    responseAttributes: responseAttributes
                )
            case .failure(let error):
                throw error
            }
        } catch {
            return AuthenticatedRequestResult(
                result: .failure(error),
                responseAttributes: responseAttributes
            )
        }
    }

    func performPublicApiKeyAuthenticationRequest(
        forTentant tenantId: String,
        applicationId: String,
        apiKeyId: String,
        userId: String
    ) async throws -> String {
        let endpoint = ParraEndpoint.postAuthentication(tenantId: tenantId)
        let url = Parra.InternalConstants.parraApiRoot
            .appendingPathComponent(endpoint.route)
        var request = URLRequest(url: url)

        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try jsonEncoder.encode(["user_id": userId])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        guard let authToken = ("api_key:" + apiKeyId).data(using: .utf8)?
            .base64EncodedString() else
        {
            throw ParraError.generic("Unable to encode API key as NSData", nil)
        }

        addHeaders(to: &request, endpoint: endpoint, for: applicationId)
        request.setValue(for: .authorization(.basic(authToken)))

        let (data, response) = try await performAsyncDataDask(request: request)

        switch response.statusCode {
        case 200:
            let credential = try jsonDecoder.decode(
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

        let (data, response) = try await urlSession.dataForRequest(
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

            urlSession.configuration.urlCache?.storeCachedResponse(
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

        guard let cache = urlSession.configuration.urlCache else {
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

    // MARK: Private

    private let dataManager: ParraDataManager

    private var authenticationProvider: ParraAuthenticationProviderFunction?

    private let urlSession: URLSessionType
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    private lazy var urlSessionDelegateProxy: ParraNetworkManagerUrlSessionDelegateProxy =
        .init(
            delegate: self
        )

    private func performRequest(
        request: URLRequest,
        credential: ParraCredential,
        config: RequestConfig = .default
    ) async -> (Result<Data, Error>, AuthenticatedRequestAttributeOptions) {
        do {
            var request = request
            request.setValue(for: .authorization(.bearer(credential.token)))

            let (
                data,
                response
            ) = try await performAsyncDataDask(request: request)

            logger
                .trace(
                    "Parra client received response. Status: \(response.statusCode)"
                )

            switch (response.statusCode, config.shouldReauthenticate) {
            case (204, _):
                return (.success(EmptyJsonObjectData), config.attributes)
            case (401, true):
                logger.trace("Request required reauthentication")
                let newCredential = try await refreshAuthentication()

                request
                    .setValue(for: .authorization(.bearer(newCredential.token)))

                return await performRequest(
                    request: request,
                    credential: newCredential,
                    config: config
                        .withoutReauthenticating()
                        .withAttribute(.requiredReauthentication)
                )
            case (400 ... 499, _):
                return (
                    .failure(ParraError.networkError(
                        request: request,
                        response: response,
                        responseData: data
                    )),
                    config.attributes
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
                        credential: credential,
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
                    attributes
                )
            default:
                return (.success(data), config.attributes)
            }
        } catch {
            return (.failure(error), config.attributes)
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

    private func performAsyncDataDask(request: URLRequest) async throws
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

        let (data, response) = try await urlSession.dataForRequest(
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

        Parra.logEvent(
            .httpRequest(
                request: request,
                response: httpResponse
            )
        )

        return (data, httpResponse)
    }

    private func addHeaders(
        to request: inout URLRequest,
        endpoint: ParraEndpoint,
        for applicationId: String
    ) {
        request.setValue(for: .accept(.applicationJson))
        request.setValue(for: .applicationId(applicationId))

        if endpoint.method.allowsBody {
            request.setValue(for: .contentType(.applicationJson))
        }

        addTrackingHeaders(toRequest: &request, for: endpoint)

        let headers = request.allHTTPHeaderFields ?? [:]

        logger.trace(
            "Finished attaching request headers for endpoint: \(endpoint.displayName)",
            headers
        )
    }

    private func addTrackingHeaders(
        toRequest request: inout URLRequest,
        for endpoint: ParraEndpoint
    ) {
        guard endpoint.isTrackingEnabled else {
            return
        }

        let headers = ParraHeader.trackingHeaderDictionary

        logger
            .trace(
                "Adding extra tracking headers to tracking enabled endpoint: \(endpoint.displayName)"
            )

        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
}
