//
//  URLSession.swift
//  Parra
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation

extension URLSession: URLSessionType {
    func dataForRequest(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        return try await data(for: request, delegate: delegate)
    }

    func dataForUploadRequest(
        for request: URLRequest,
        from data: Data,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        return try await upload(
            for: request,
            from: data,
            delegate: delegate
        )
    }
}
