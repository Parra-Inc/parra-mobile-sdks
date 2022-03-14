//
//  ParraNetworkManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation


public typealias NetworkCompletionHandler<T> = (Result<T, ParraError>) -> Void

private let kEmptyJsonObjectData = "{}".data(using: .utf8)!

struct EmptyRequestObject: Encodable {}
struct EmptyResponseObject: Decodable {}

actor ParraNetworkManager {
    private let dataManager: ParraDataManager
    
    internal private(set) var authenticationProvider: ParraFeedbackAuthenticationProvider?

    internal lazy var urlSession: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    init(dataManager: ParraDataManager) {
        self.dataManager = dataManager
    }
    
    func updateAuthenticationProvider(_ provider: ParraFeedbackAuthenticationProvider?) async {
        authenticationProvider = provider
    }
    
    func refreshAuthentication() async throws -> ParraCredential {
        guard let authenticationProvider = authenticationProvider else {
            throw ParraError.missingAuthentication
        }
        
        do {
            let credential = try await authenticationProvider()
            
            await dataManager.updateCredential(credential: credential)
            
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
        // TODO: Add header for current library versions. Can we detect which Parra libs we have, not just core?
        // https://stackoverflow.com/a/59714965/716216
        
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
                                credential: ParraCredential,
                                shouldReauthenticate: Bool = true) async throws -> Data {
        
        var request = request
        request.setValue("Bearer \(credential.token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await performAsyncDataDask(request: request)
        switch response.statusCode {
        case 204:
            return kEmptyJsonObjectData
        case 401:
            if shouldReauthenticate {
                let newCredential = try await refreshAuthentication()

                request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: "Authorization")

                return try await performRequest(
                    request: request,
                    credential: newCredential,
                    shouldReauthenticate: false
                )
            } else {
                return data
            }
        case 400...499:
            throw ParraError.networkError(
                "Client error \(response.statusCode): \(response.debugDescription)"
            )
        case 500...599:
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
