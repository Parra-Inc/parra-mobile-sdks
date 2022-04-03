//
//  ParraNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation


public typealias NetworkCompletionHandler<T> = (Result<T, ParraError>) -> Void

internal let kEmptyJsonObjectData = "{}".data(using: .utf8)!

struct EmptyRequestObject: Codable {}
struct EmptyResponseObject: Codable {}

protocol URLSessionType {
    func dataForRequest(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

protocol NetworkManagerType {
    init(dataManager: ParraDataManager,
         urlSession: URLSessionType,
         jsonEncoder: JSONEncoder,
         jsonDecoder: JSONDecoder)
    
    var authenticationProvider: ParraFeedbackAuthenticationProvider? { get }

    func updateAuthenticationProvider(_ provider: ParraFeedbackAuthenticationProvider?) async
    func refreshAuthentication() async throws -> ParraCredential
}

class ParraNetworkManager: NetworkManagerType {
    private let dataManager: ParraDataManager
    
    internal private(set) var authenticationProvider: ParraFeedbackAuthenticationProvider?

    let urlSession: URLSessionType
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    
    required init(dataManager: ParraDataManager,
                  urlSession: URLSessionType,
                  jsonEncoder: JSONEncoder = JSONEncoder.parraEncoder,
                  jsonDecoder: JSONDecoder = JSONDecoder.parraDecoder) {
        self.dataManager = dataManager
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    func updateAuthenticationProvider(_ provider: ParraFeedbackAuthenticationProvider?) {
        authenticationProvider = provider
    }
    
    func refreshAuthentication() async throws -> ParraCredential {
        guard let authenticationProvider = authenticationProvider else {
            throw ParraError.missingAuthentication
        }
        
        do {
            let credential = try await authenticationProvider()
            
            await dataManager.updateCredential(
                credential: credential
            )
            
            return credential
        } catch let error {
            throw ParraError.authenticationFailed(error.localizedDescription)
        }
    }
    
    func performAuthenticatedRequest<T: Decodable>(route: String,
                                                   method: HttpMethod,
                                                   cachePolicy: URLRequest.CachePolicy? = nil) async throws -> T {
        return try await performAuthenticatedRequest(
            route: route,
            method: method,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject()
        )
    }
    
    func performAuthenticatedRequest<T: Decodable, U: Encodable>(route: String,
                                                                 method: HttpMethod,
                                                                 cachePolicy: URLRequest.CachePolicy? = nil,
                                                                 body: U) async throws -> T {

        let url = Parra.Constant.parraApiRoot.appendingPathComponent(route)
        let credential = await dataManager.getCurrentCredential()
        
        let nextCredential: ParraCredential
        if let credential = credential {
            nextCredential = credential
        } else {
            nextCredential = try await refreshAuthentication()
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy ?? .useProtocolCachePolicy)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        for (header, value) in libraryVersionHeaders() {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        if method.allowsBody {
            request.httpBody = try jsonEncoder.encode(body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
        request.setValue("Bearer \(credential.token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await performAsyncDataDask(request: request)
        switch (response.statusCode, shouldReauthenticate) {
        case (204, _):
            return kEmptyJsonObjectData
        case (401, true):
            let newCredential = try await refreshAuthentication()

            request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: "Authorization")

            return try await performRequest(
                request: request,
                credential: newCredential,
                shouldReauthenticate: false
            )
        case (400...499, _):
            throw ParraError.networkError(
                "Client error \(response.statusCode): \(response.debugDescription)"
            )
        case (500...599, _):
            throw ParraError.networkError(
                "Server error \(response.statusCode): \(response.debugDescription)"
            )
        default:
            return data
        }
    }
    
    private func performAsyncDataDask(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
#if DEBUG
        try await Task.sleep(nanoseconds: 1_000_000_000)
#endif

        let (data, response) = try await urlSession.dataForRequest(for: request, delegate: nil)
        
        // It is documented that for data tasks, response is always actually HTTPURLResponse
        return (data, response as! HTTPURLResponse)
    }

    private func libraryVersionHeaders() -> [String: String] {
        var headers = [String: String]()
        
        for (moduleName, module) in Parra.registeredModules {
            headers["parra-\(moduleName.lowercased())-version"] = type(of: module).libraryVersion()
        }
        
        return headers
    }
}
