//
//  URLSession.swift
//  ParraCore
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation

@available(iOS 13.0.0, *)
extension URLSession: URLSessionType {
    // Work around for the fact that we're unable to add the iOS 13+ availability attribute to URLSession's
    //declaration of data(for:delegate:).
    func dataForRequest(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, *) {
            return try await data(for: request, delegate: delegate)
        } else {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, HTTPURLResponse), Error>) in
                dataTask(with: request) { data, response, error in
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
