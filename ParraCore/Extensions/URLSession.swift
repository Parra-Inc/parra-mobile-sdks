//
//  URLSession.swift
//  ParraCore
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation

@available(iOS 13.0.0, *)
extension URLSession: URLSessionType {
    func dataForRequest(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        return try await data(for: request, delegate: delegate)
    }
}
