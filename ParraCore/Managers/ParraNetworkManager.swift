//
//  ParraNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public struct AuthenticatedRequestAttributeOptions: OptionSet {
    public let rawValue: Int

    public static let requiredReauthentication = AuthenticatedRequestAttributeOptions(rawValue: 1 << 0)
    public static let requiredRetry = AuthenticatedRequestAttributeOptions(rawValue: 1 << 1)
    public static let exceededRetryLimit = AuthenticatedRequestAttributeOptions(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct AuthenticatedRequestResult<T: Decodable> {
    public let result: Result<T, Error>
    public let attributes: AuthenticatedRequestAttributeOptions

    init(result: Result<T, Error>,
         responseAttributes: AuthenticatedRequestAttributeOptions = []) {

        self.result = result
        self.attributes = responseAttributes
    }
}

public typealias NetworkCompletionHandler<T> = (Result<T, ParraError>) -> Void

internal let kEmptyJsonObjectData = "{}".data(using: .utf8)!

internal struct EmptyRequestObject: Codable {}
internal struct EmptyResponseObject: Codable {}

internal protocol URLSessionType {
    func dataForRequest(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask

    var configuration: URLSessionConfiguration { get }
}

internal protocol NetworkManagerType {
    init(dataManager: ParraDataManager,
         urlSession: URLSessionType,
         jsonEncoder: JSONEncoder,
         jsonDecoder: JSONDecoder)
    
    var authenticationProvider: ParraAuthenticationProviderFunction? { get }
    
    func updateAuthenticationProvider(_ provider: ParraAuthenticationProviderFunction?) async
    func refreshAuthentication() async throws -> ParraCredential
}

internal class ParraNetworkManager: NetworkManagerType {
    private let dataManager: ParraDataManager
    
    internal private(set) var authenticationProvider: ParraAuthenticationProviderFunction?
    
    private let urlSession: URLSessionType
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    internal required init(dataManager: ParraDataManager,
                           urlSession: URLSessionType,
                           jsonEncoder: JSONEncoder = JSONEncoder.parraEncoder,
                           jsonDecoder: JSONDecoder = JSONDecoder.parraDecoder
    ) {
        self.dataManager = dataManager
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    internal func updateAuthenticationProvider(_ provider: ParraAuthenticationProviderFunction?) {
        authenticationProvider = provider
    }
    
    internal func refreshAuthentication() async throws -> ParraCredential {
        parraLogDebug("Performing reauthentication for Parra")

        guard let authenticationProvider = authenticationProvider else {
            throw ParraError.missingAuthentication
        }
        
        do {
            parraLogInfo("Invoking Parra authentication provider")

            let token = try await authenticationProvider()
            let credential = ParraCredential(token: token)
            
            await dataManager.updateCredential(
                credential: credential
            )

            parraLogInfo("Reauthentication with Parra succeeded")

            return credential
        } catch let error {
            let framing = "╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍"
            parraLogError("\n\(framing)\n\nReauthentication with Parra failed.\nInvoking the authProvider passed to Parra.initialize failed with error: \(error.localizedDescription)\n\n\(framing)")
            throw ParraError.authenticationFailed(error.localizedDescription)
        }
    }

    internal func performAuthenticatedRequest<T: Decodable>(route: String,
                                                            method: HttpMethod,
                                                            queryItems: [String: String] = [:],
                                                            config: RequestConfig = .default,
                                                            cachePolicy: URLRequest.CachePolicy? = nil
    ) async -> AuthenticatedRequestResult<T> {
        return await performAuthenticatedRequest(
            route: route,
            method: method,
            queryItems: queryItems,
            config: config,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }
    
    internal func performAuthenticatedRequest<T: Decodable, U: Encodable>(route: String,
                                                                          method: HttpMethod,
                                                                          queryItems: [String: String] = [:],
                                                                          config: RequestConfig = .default,
                                                                          cachePolicy: URLRequest.CachePolicy? = nil,
                                                                          body: U
    ) async -> AuthenticatedRequestResult<T> {
        var responseAttributes: AuthenticatedRequestAttributeOptions = []

        parraLogTrace("Performing authenticated request to route: \(method.rawValue) \(route)")

        do {
            let url = Parra.Constant.parraApiRoot.appendingPathComponent(route)
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw ParraError.custom("Failed to create components for url: \(url)", nil)
            }

            urlComponents.setQueryItems(with: queryItems)
            let credential = await dataManager.getCurrentCredential()

            let nextCredential: ParraCredential
            if let credential {
                nextCredential = credential
            } else {
                nextCredential = try await refreshAuthentication()
            }

            var request = URLRequest(
                url: urlComponents.url!,
                cachePolicy: cachePolicy ?? .useProtocolCachePolicy
            )

            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: .accept)

            addStandardHeaders(toRequest: &request)

            if method.allowsBody {
                request.httpBody = try jsonEncoder.encode(body)
                request.setValue("application/json", forHTTPHeaderField: .contentType)
            }

            let (result, attributes) = await performRequest(
                request: request,
                credential: nextCredential,
                config: config
            )

            responseAttributes.insert(attributes)

            switch result {
            case .success(let data):
                parraLogTrace("Parra client received success response")

                let response = try jsonDecoder.decode(T.self, from: data)

                return AuthenticatedRequestResult(
                    result: .success(response),
                    responseAttributes: responseAttributes
                )
            case .failure(let error):
                throw error
            }
        } catch let error {
            return AuthenticatedRequestResult(
                result: .failure(error),
                responseAttributes: responseAttributes
            )
        }
    }
    
    private func performRequest(request: URLRequest,
                                credential: ParraCredential,
                                config: RequestConfig = .default) async -> (Result<Data, Error>, AuthenticatedRequestAttributeOptions) {
        do {
            var request = request
            request.setValue("Bearer \(credential.token)", forHTTPHeaderField: .authorization)

            let (data, response) = try await performAsyncDataDask(request: request)

            parraLogTrace("Parra client received response. Status: \(response.statusCode)")

            switch (response.statusCode, config.shouldReauthenticate) {
            case (204, _):
                return (.success(kEmptyJsonObjectData), config.attributes)
            case (401, true):
                parraLogTrace("Request required reauthentication")
                let newCredential = try await refreshAuthentication()

                request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: .authorization)

                return await performRequest(
                    request: request,
                    credential: newCredential,
                    config: config
                        .withoutReauthenticating()
                        .withAttribute(.requiredReauthentication)
                )
            case (400...499, _):
#if DEBUG
                if let dataString = try? jsonDecoder.decode(AnyCodable.self, from: data),
                   let prettyData = try? jsonEncoder.encode(dataString),
                   let prettyString = String(data: prettyData, encoding: .utf8) {

                    parraLogTrace("Received 400...499 status in response")
                    if data != kEmptyJsonObjectData {
                        parraLogTrace(prettyString)
                    }

                    if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                        parraLogTrace("Request data was:")
                        parraLogTrace(bodyString)
                    }
                }
#endif

                return (
                    .failure(ParraError.networkError(
                        status: response.statusCode,
                        message: response.debugDescription,
                        request: request
                    )),
                    config.attributes
                )
            case (500...599, _):
#if DEBUG
                if let dataString = try? jsonDecoder.decode(AnyCodable.self, from: data),
                   let prettyData = try? jsonEncoder.encode(dataString),
                   let prettyString = String(data: prettyData, encoding: .utf8) {

                    parraLogTrace("Received 500...599 status in response")
                    if data != kEmptyJsonObjectData {
                        parraLogTrace(prettyString)
                    }
                }
#endif

                if config.shouldRetry {
                    parraLogTrace("Retrying previous request")

                    let nextConfig = config
                        .afterRetrying()
                        .withAttribute(.requiredRetry)

                    try await Task.sleep(nanoseconds: nextConfig.retryDelayNs)

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
                        status: response.statusCode,
                        message: response.debugDescription,
                        request: request
                    )),
                    attributes
                )
            default:
                return (.success(data), config.attributes)
            }
        } catch let error {
            return (.failure(error), config.attributes)
        }
    }

    func performPublicApiKeyAuthenticationRequest(
        forTentant tenantId: String,
        apiKeyId: String,
        userId: String
    ) async throws -> String {
        let url = Parra.Constant.parraApiRoot.appendingPathComponent("tenants/\(tenantId)/issuers/public/auth/token")
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = try jsonEncoder.encode(["user_id": userId])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        guard let authData = ("api_key:" + apiKeyId).data(using: .utf8)?.base64EncodedString() else {
            throw ParraError.custom("Unable to encode API key as NSData", nil)
        }
        
        addStandardHeaders(toRequest: &request)
        request.setValue("Basic \(authData)", forHTTPHeaderField: .authorization)

        let (data, response) = try await performAsyncDataDask(request: request)

        switch (response.statusCode) {
        case 200:
            let credential = try jsonDecoder.decode(ParraCredential.self, from: data)

            return credential.token
        default:
            throw ParraError.networkError(
                status: response.statusCode,
                message: response.debugDescription,
                request: request
            )
        }
    }

    internal func performBulkAssetCachingRequest(assets: [Asset]) async {
        parraLogTrace("Performing bulk asset caching request for \(assets.count) asset(s)")
        let _ = await assets.asyncMap { asset in
            return try? await fetchAsset(asset: asset)
        }
    }

    internal func fetchAsset(asset: Asset) async throws -> UIImage? {
        parraLogTrace("Fetching asset: \(asset.id)", [
            "url": asset.url
        ])

        let request = request(for: asset)

        let (data, response) = try await urlSession.dataForRequest(for: request, delegate: nil)
        let httpResponse = response as! HTTPURLResponse

        defer {
            parraLogTrace("Caching asset: \(asset.id)")

            let cacheResponse = CachedURLResponse(
                response: response,
                data: data,
                storagePolicy: .allowed
            )

            urlSession.configuration.urlCache?.storeCachedResponse(cacheResponse, for: request)
        }

        if httpResponse.statusCode < 300 {
            parraLogTrace("Successfully retreived image for asset: \(asset.id)")

            return UIImage(data: data)
        }

        parraLogTrace("Failed to download image for asset: \(asset.id)")

        return nil
    }

    internal func isAssetCached(asset: Asset) -> Bool {
        parraLogTrace("Checking if asset is cached: \(asset.id)")

        guard let cache = urlSession.configuration.urlCache else {
            parraLogTrace("Cache is missing")

            return false
        }

        guard let cachedResponse = cache.cachedResponse(for: request(for: asset)) else {
            parraLogTrace("Cache miss for asset: \(asset.id)")
            return false
        }

        guard cachedResponse.storagePolicy != .notAllowed else {
            parraLogTrace("Storage policy disallowed for asset: \(asset.id)")

            return false
        }

        parraLogTrace("Cache hit for asset: \(asset.id)")

        return true
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

    private func performAsyncDataDask(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
#if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
#endif
        
        let (data, response) = try await urlSession.dataForRequest(for: request, delegate: nil)
        
        // It is documented that for data tasks, response is always actually HTTPURLResponse
        return (data, response as! HTTPURLResponse)
    }

    private func addStandardHeaders(toRequest request: inout URLRequest) {
        for (header, value) in libraryVersionHeaders() {
            request.setValue(value, forHTTPHeaderField: header)
        }

        for (header, value) in additionalHeaders() {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
    
    private func libraryVersionHeaders() -> [String: String] {
        var headers = [String: String]()
        
        for (moduleName, module) in Parra.registeredModules {
            headers[ParraHeader.moduleVersion(module: moduleName).prefixedHeaderName] = type(of: module).libraryVersion()
        }
        
        return headers
    }
    
    private func additionalHeaders() -> [String: String] {
        var headers = [String: String]()
        
#if DEBUG
        headers[ParraHeader.debug.prefixedHeaderName] = "debug"
#endif
        
        headers[ParraHeader.os.prefixedHeaderName] = UIDevice.current.systemName
        headers[ParraHeader.osVersion.prefixedHeaderName] = UIDevice.current.systemVersion
        headers[ParraHeader.device.prefixedHeaderName] = UIDevice.current.name
        headers[ParraHeader.appLocale.prefixedHeaderName] = UIDevice.current.name
        
        if let deviceLanguageCode = NSLocale.current.languageCode {
            headers[ParraHeader.deviceLocale.prefixedHeaderName] = deviceLanguageCode
        }
        
        if let appLanguageCode = Locale.preferredLanguages.first {
            headers[ParraHeader.appLocale.prefixedHeaderName] = appLanguageCode
        }
        
        headers[ParraHeader.timeZoneOffset.prefixedHeaderName] = String(TimeZone.current.secondsFromGMT())
        if let timeZoneAbbreviation = TimeZone.current.abbreviation() {
            headers[ParraHeader.timeZoneAbbreviation.prefixedHeaderName] = timeZoneAbbreviation
        }
        
        return headers
    }
}
