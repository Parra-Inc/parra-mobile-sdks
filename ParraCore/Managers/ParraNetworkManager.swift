//
//  ParraNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

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
                           jsonDecoder: JSONDecoder = JSONDecoder.parraDecoder) {
        self.dataManager = dataManager
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    internal func updateAuthenticationProvider(_ provider: ParraAuthenticationProviderFunction?) {
        authenticationProvider = provider
    }
    
    internal func refreshAuthentication() async throws -> ParraCredential {
        guard let authenticationProvider = authenticationProvider else {
            throw ParraError.missingAuthentication
        }
        
        do {
            let token = try await authenticationProvider()
            let credential = ParraCredential(token: token)
            
            await dataManager.updateCredential(
                credential: credential
            )
            
            return credential
        } catch let error {
            throw ParraError.authenticationFailed(error.localizedDescription)
        }
    }
    
    internal func performAuthenticatedRequest<T: Decodable>(route: String,
                                                            method: HttpMethod,
                                                            queryItems: [String: String] = [:],
                                                            cachePolicy: URLRequest.CachePolicy? = nil) async throws -> T {
        return try await performAuthenticatedRequest(
            route: route,
            method: method,
            queryItems: queryItems,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }
    
    internal func performAuthenticatedRequest<T: Decodable, U: Encodable>(route: String,
                                                                          method: HttpMethod,
                                                                          queryItems: [String: String] = [:],
                                                                          cachePolicy: URLRequest.CachePolicy? = nil,
                                                                          body: U) async throws -> T {
        
        let url = Parra.Constant.parraApiRoot.appendingPathComponent(route)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.setQueryItems(with: queryItems)
        let credential = await dataManager.getCurrentCredential()
        
        let nextCredential: ParraCredential
        if let credential = credential {
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
        
        let data = try await performRequest(
            request: request,
            credential: nextCredential
        )
        
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    private func performRequest(request: URLRequest,
                                credential: ParraCredential,
                                shouldReauthenticate: Bool = true) async throws -> Data {
        
        var request = request
        request.setValue("Bearer \(credential.token)", forHTTPHeaderField: .authorization)
        
        let (data, response) = try await performAsyncDataDask(request: request)
        switch (response.statusCode, shouldReauthenticate) {
        case (204, _):
            return kEmptyJsonObjectData
        case (401, true):
            let newCredential = try await refreshAuthentication()
            
            request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: .authorization)
            
            return try await performRequest(
                request: request,
                credential: newCredential,
                shouldReauthenticate: false
            )
                config: config.withoutReauthenticating()
            )
        case (400...599, _):
            throw ParraError.networkError(
                status: response.statusCode,
                message: response.debugDescription,
                request: request
            )
        default:
            return data
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

        let authData = ("api_key:" + apiKeyId).data(using: .utf8)!.base64EncodedString()
        
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
        let _ = await assets.asyncMap { asset in
            return try? await fetchAsset(asset: asset)
        }
    }

    internal func fetchAsset(asset: Asset) async throws -> UIImage? {
        let request = request(for: asset)

        let (data, response) = try await urlSession.dataForRequest(for: request, delegate: nil)
        let httpResponse = response as! HTTPURLResponse

        defer {
            let cacheResponse = CachedURLResponse(
                response: response,
                data: data,
                storagePolicy: .allowed
            )

            urlSession.configuration.urlCache?.storeCachedResponse(cacheResponse, for: request)
        }

        if httpResponse.statusCode < 300 {
            return UIImage(data: data)
        }

        return nil
    }

    internal func isAssetCached(asset: Asset) -> Bool {
        guard let cache = urlSession.configuration.urlCache else {
            return false
        }

        guard let cachedResponse = cache.cachedResponse(for: request(for: asset)) else {
            return false
        }

        return cachedResponse.storagePolicy != .notAllowed
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
        try await Task.sleep(nanoseconds: 1_000_000_000)
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
