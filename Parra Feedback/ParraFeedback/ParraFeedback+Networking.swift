//
//  ParraFeedback+Networking.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

public typealias NetworkCompletionHandler<T> = (Result<T, ParraFeedbackError>) -> Void

extension ParraFeedback {
    func performAuthenticatedRequest<T: Codable>(route: String,
                                     method: HttpMethod,
                                     authenticationProvider: ParraFeedbackAuthenticationProvider) async throws -> T {
        let url = Constants.parraApiRoot.appendingPathComponent(route)
        let credential = await dataManager.getCurrentCredential()

        let nextCredential: ParraFeedbackCredential
        if let credential = credential {
            nextCredential = credential
        } else {
            nextCredential = try await authenticationProvider()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let data = try await performRequest(
            request: request,
            credential: nextCredential,
            authenticationProvider: authenticationProvider
        )
        
        return try JSONDecoder.parraDecoder.decode(T.self, from: data)
    }
        
    private func performRequest(request: URLRequest,
                                credential: ParraFeedbackCredential,
                                authenticationProvider: ParraFeedbackAuthenticationProvider) async throws -> Data {

        var request = request
        request.setValue("Bearer \(credential.token)", forHTTPHeaderField: "Authorization")

        var (data, response) = try await performAsyncDataDask(request: request)
        if response.statusCode == 401 {
            let newCredential = try await authenticationProvider()
            request.setValue("Bearer \(newCredential.token)", forHTTPHeaderField: "Authorization")

            (data, response) = try await performAsyncDataDask(request: request)
        }
        
        return data
    }
    
    private func performAsyncDataDask(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
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
