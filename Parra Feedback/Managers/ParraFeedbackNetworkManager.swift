//
//  ParraFeedbackNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    
    var allowsBody: Bool {
        return [.put, .post, .patch].contains(self)
    }
}

public typealias NetworkCompletionHandler<T> = (Result<T, ParraFeedbackError>) -> Void

private let kEmptyJsonObjectData = "{}".data(using: .utf8)!

struct EmptyRequestObject: Encodable {}
struct EmptyResponseObject: Decodable {}

actor ParraFeedbackNetworkManager {
    private let dataManager: ParraFeedbackDataManager
    
    internal private(set) var authenticationProvider: ParraFeedbackAuthenticationProvider?

    internal lazy var urlSession: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    init(dataManager: ParraFeedbackDataManager) {
        self.dataManager = dataManager
    }
    
    func updateAuthenticationProvider(_ provider: ParraFeedbackAuthenticationProvider?) async {
        authenticationProvider = provider
    }
    
    func refreshAuthentication() async throws -> ParraFeedbackCredential {
        guard let authenticationProvider = authenticationProvider else {
            throw ParraFeedbackError.missingAuthentication
        }
        
        do {
            let credential = try await authenticationProvider()
            
            await dataManager.updateCredential(credential: credential)
            
            return credential
        } catch let error {
            throw ParraFeedbackError.authenticationFailed(error)
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

        let url = ParraFeedback.Constant.parraApiRoot.appendingPathComponent(route)
        let credential = await dataManager.getCurrentCredential()
        
        let nextCredential: ParraFeedbackCredential
        if let credential = credential {
            nextCredential = credential
        } else {
            nextCredential = try await refreshAuthentication()
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy ?? .useProtocolCachePolicy)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if method.allowsBody {
            request.httpBody = try JSONEncoder.parraEncoder.encode(body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let data = try await performRequest(
            request: request,
            credential: nextCredential
        )
        
        return try JSONDecoder.parraDecoder.decode(T.self, from: data)
    }
    
    private func performRequest(request: URLRequest,
                                credential: ParraFeedbackCredential) async throws -> Data {
        
        var request = request
        request.setValue("Bearer \(credential.token)", forHTTPHeaderField: "Authorization")
        
        var (data, response) = try await performAsyncDataDask(request: request)
        if response.statusCode == 401 {
            let newCredential = try await refreshAuthentication()
            request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: "Authorization")
            
            (data, response) = try await performAsyncDataDask(request: request)
        } else if response.statusCode == 204 {
            return kEmptyJsonObjectData
        }
        
        return data
    }
    
    private func performAsyncDataDask(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
#if DEBUG
        try await Task.sleep(nanoseconds: 1_000_000_000)
#endif

        if #available(iOS 15.0, *) {
            let (data, response) = try await urlSession.data(for: request)
            
            // It is documented that for data tasks, response is always actually HTTPURLResponse
            return (data, response as! HTTPURLResponse)
        } else {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, HTTPURLResponse), Error>) in
                urlSession.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        // It is documented that for data tasks, response is always actually HTTPURLResponse
                        continuation.resume(returning: (data!, response as! HTTPURLResponse))
                    }
                }.resume()
            }
        }
    }

}
