//
//  Server+performRequest.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
#if DEBUG
import WebKit
#endif

private let logger = Logger()

extension Server {
    func createRequest(
        to endpoint: ApiEndpoint,
        queryItems: [String: String] = [:],
        config: RequestConfig = .default,
        cachePolicy: URLRequest.CachePolicy? = nil,
        body: Data? = nil
    ) throws -> URLRequest {
        let method = endpoint.method

        let headerFactory = HeaderFactory(
            appState: appState,
            appConfig: appConfig
        )

        let url = try EndpointResolver.resolve(
            endpoint: endpoint,
            using: appState
        )

        var request = try URLRequest(
            with: queryItems,
            url: url,
            cachePolicy: cachePolicy
        )

        request.httpMethod = method.rawValue
        if let body, method.allowsBody {
            request.httpBody = body
        }

        addHeaders(
            to: &request,
            endpoint: endpoint,
            for: appState,
            with: headerFactory
        )

        return request
    }

    func performFormPostRequest<T: Decodable>(
        to url: URL,
        data: [String: String],
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeout: TimeInterval? = nil,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        var components = URLComponents()
        components.percentEncodedQueryItems = data.asCorrectlyEscapedQueryItems

        var request = URLRequest(
            url: url,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy
        )

        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        request.timeoutInterval = timeout ?? configuration.urlSession
            .configuration.timeoutIntervalForRequest

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
        timeout: TimeInterval? = nil,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        return try await performRequest(
            to: url,
            method: method,
            queryItems: queryItems,
            cachePolicy: cachePolicy,
            body: EmptyRequestObject(),
            timeout: timeout,
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
        timeout: TimeInterval?,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> T {
        var request = try URLRequest(
            with: queryItems,
            url: url,
            cachePolicy: cachePolicy
        )

        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout ?? configuration.urlSession
            .configuration.timeoutIntervalForRequest
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
            request: request
        )

        guard response.statusCode == 200 else {
            throw ParraError.networkError(
                request: request,
                response: response,
                responseData: data
            )
        }

        return try decodeResponse(
            from: data,
            as: T.self
        )
    }

    func performAsyncDataTask(
        request: URLRequest
    ) async throws -> (Data, HTTPURLResponse) {
        try await sleepInDebug()

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: urlSessionDelegateProxy
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            // It is documented that for data tasks, response is always actually
            // HTTPURLResponse, so this should never happen.
            throw ParraError
                .message(
                    "Unexpected networking error. HTTP response was unexpected class"
                )
        }

        #if DEBUG
        if let query = request.url?.query(percentEncoded: true),
           let decoded = query.removingPercentEncoding,
           let reencoded = decoded.addingPercentEncoding(
               withAllowedCharacters: .rfc3986Unreserved
           )
        {
            if query != reencoded {
                assertionFailure(
                    "Request to: \(request.url!) contains reserved characters in query: \(query)"
                )
            }
        }

        // Auto display HTML errors like those from Cloudflare in a popup
        // webview.
        if httpResponse.statusCode >= 400 {
            if let bodyString = String(data: data, encoding: .utf8) {
                if let contentType = httpResponse.value(
                    forHTTPHeaderField: "Content-Type"
                ), contentType.lowercased().contains("text/html") {
                    if bodyString.hasPrefix("<") {
                        await MainActor.run {
                            let webview = WKWebView()
                            webview.loadHTMLString(bodyString, baseURL: nil)

                            let vc = UIViewController()
                            vc.view = webview

                            UIViewController.topMostViewController()?.present(
                                vc,
                                animated: true
                            )
                        }
                    }
                }
            }
        }

        #endif

        return (data, httpResponse)
    }

    func performAsyncMultipartUploadTask(
        request: URLRequest,
        formFields: [MultipartFormField]
    ) async throws -> (Data, HTTPURLResponse) {
        try await sleepInDebug()

        var urlRequest = request

        assert(
            urlRequest.httpMethod?.uppercased() == "POST",
            "Multipart form upload only supports POST requests"
        )

        assert(
            urlRequest.httpBody == nil,
            "Multipart form upload does not support setting the httpBody property. It will be overridden."
        )

        let boundary = UUID().uuidString

        urlRequest.setValue(
            for: .contentType(
                .multipartFormData(boundary: boundary)
            )
        )

        var data = Data()

        for field in formFields {
            data.append(field.fieldData(with: boundary))
        }

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, response) = try await configuration.urlSession
            .dataForUploadRequest(
                for: urlRequest,
                from: data,
                delegate: urlSessionDelegateProxy
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            // It is documented that for data tasks, response is always actually
            // HTTPURLResponse, so this should never happen.
            throw ParraError
                .message(
                    "Unexpected networking error. HTTP response was unexpected class"
                )
        }

        return (responseData, httpResponse)
    }

    private func sleepInDebug() async throws {
        #if DEBUG
        // There is a different delay added in the UrlSession mocks that
        // slows down tests. This delay is specific to helping prevent us
        // from introducing UI without proper loading states.
        if NSClassFromString("XCTestCase") == nil {
            try await Task.sleep(for: 1.0)
        }
        #endif
    }
}
