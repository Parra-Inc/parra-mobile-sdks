//
//  Server+performRequest.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Server {
    func performFormPostRequest<T: Decodable>(
        to url: URL,
        data: [String: String],
        cachePolicy: URLRequest.CachePolicy? = nil,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        var components = URLComponents()
        components.percentEncodedQueryItems = data.queryItems

        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy
        )

        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        request.setValue(for: .accept(.applicationJson))
        request.setValue(for: .contentType(.applicationFormUrlEncoded))

        return try await performRequest(
            request: request,
            delegate: delegate
        )
    }

    func performRequest<T: Decodable>(
        to url: URL,
        method: HttpMethod = .get,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        return try await performRequest(
            to: url,
            method: method,
            queryItems: queryItems,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject(),
            delegate: delegate
        )
    }

    /// URLs not controlled by Parra/external APIs/etc.
    func performRequest<T: Decodable>(
        to url: URL,
        method: HttpMethod = .get,
        queryItems: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: some Encodable,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy
        )

        request.httpMethod = method.rawValue
        if method.allowsBody {
            request.httpBody = try configuration.jsonEncoder.encode(body)
        }

        return try await performRequest(
            request: request,
            delegate: delegate
        )
    }

    private func performRequest<T: Decodable>(
        request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        let (data, response) = try await performAsyncDataTask(
            request: request,
            delegate: delegate
        )

        guard response.statusCode == 200 else {
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }

        return try configuration.jsonDecoder.decode(
            T.self,
            from: data
        )
    }

    func performAsyncDataTask(
        request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        #if DEBUG
        // There is a different delay added in the UrlSession mocks that
        // slows down tests. This delay is specific to helping prevent us
        // from introducing UI without proper loading states.
        if NSClassFromString("XCTestCase") == nil {
            try await Task.sleep(for: 1.0)
        }
        #endif

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: delegate
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            // It is documented that for data tasks, response is always actually
            // HTTPURLResponse, so this should never happen.
            throw ParraError
                .message(
                    "Unexpected networking error. HTTP response was unexpected class"
                )
        }

        return (data, httpResponse)
    }
}
