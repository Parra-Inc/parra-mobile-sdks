//
//  MockURLSession.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import Parra

typealias DataTaskResponse = (data: Data?, response: URLResponse?, error: Error?)
typealias DataTaskResolver = (_ request: URLRequest) -> DataTaskResponse

internal class MockURLSession: URLSessionType {
    var configuration: URLSessionConfiguration = .default

    private var expectedEndpoints = [
        ParraEndpoint: (testCase: XCTestCase, expectation: XCTestExpectation)
    ]()

    private func resolve(_ request: URLRequest) -> DataTaskResponse {
        guard let endpoint = matchingEndpoint(for: request) else {
            let route = request.url!.absoluteString
            return (
                nil,
                createTestResponse(
                    route: route,
                    statusCode: 400
                ),
                ParraError.custom("URL provided with request did not match any ParraEndpoint case. \(route)", nil)
            )
        }

        guard let endpointExpectation = expectedEndpoints[endpoint] else {
            return (
                nil,
                createTestResponse(
                    route: request.url!.absoluteString,
                    statusCode: 400
                ),
                ParraError.custom("Endpoint invoked without any expectation set. \(endpoint.slug)", nil)
            )
        }

        defer {
            expectedEndpoints.removeValue(forKey: endpoint)
        }

        do {
            let responseData = try endpoint.getMockResponseData()

            // We were able to get response data for this mocked object. Fulfill the
            // expectation. Possibly expand this in the future to allow setting expected
            // status codes.
            endpointExpectation.expectation.fulfill()

            endpointExpectation.testCase.addJsonAttachment(
                data: responseData,
                name: "Response object",
                lifetime: .keepAlways
            )

            return (
                responseData,
                createTestResponse(
                    route: endpoint.route,
                    statusCode: 200
                ),
                nil
            )
        } catch let error {
            if let body = request.httpBody {
                endpointExpectation.testCase.addJsonAttachment(
                    data: body,
                    name: "Request body"
                )
            }

            if let headers = request.allHTTPHeaderFields {
                try? endpointExpectation.testCase.addJsonAttachment(
                    value: headers,
                    name: "Request headers"
                )
            }

            return (
                nil,
                createTestResponse(
                    route: endpoint.route,
                    statusCode: 400
                ),
                error
            )
        }
    }

    func dataForRequest(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        return try await data(
            for: request,
            delegate: delegate
        )
    }

    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        let (data, response, error) = resolve(request)

        if let error {
            throw error
        }

        return (data!, response!)
    }

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (DataTaskResponse) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask(
            request: request,
            dataTaskResolver: self.resolve,
            handler: completionHandler
        )
    }

    func expectInvocation(
        of endpoint: ParraEndpoint,
        in testcase: XCTestCase
    ) -> XCTestExpectation {
        let expectation = testcase.expectation(
            description: "Expecting endpoint \(endpoint.slug) to be called"
        )
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 1

        // TODO: What if an entry for this endpoint already exists?
        expectedEndpoints[endpoint] = (testcase, expectation)

        return expectation
    }

    /// Attempts to find a ParraEndpoint case that most closely matches the request url.
    /// This is done by iterating over the path components of both the request url, and the
    /// expected url components of each endpoint and comparing non-variable components.
    private func matchingEndpoint(for request: URLRequest) -> ParraEndpoint? {
        guard let url = request.url else {
            return nil
        }

        let apiRoot = Parra.InternalConstants.parraApiRoot
        let urlString = url.absoluteString
        let rootString = apiRoot.absoluteString

        guard urlString.starts(with: rootString) else {
            return nil
        }

        let suffix = urlString.dropFirst(rootString.count)
        let remainingComponents = suffix.split(separator: "/")

        for endpoint in ParraEndpoint.allCases {
            let slugComponents = endpoint.slug.split(separator: "/")

            // If they don't have the same path component count, it's an easy no-match.
            guard remainingComponents.count == slugComponents.count else {
                continue
            }

            var endpointMatches = true
            for (index, slugComponent) in slugComponents.enumerated() {
                // Slug components starting with : are used to denote a variable path
                // component and do not need to be compared.
                guard !slugComponent.starts(with: ":") else {
                    continue
                }

                let comparisonComponent = remainingComponents[index]
                let matches = slugComponent == comparisonComponent

                // Anything component not matching prevents a match.
                if !matches {
                    endpointMatches = false
                    break
                }
            }

            if endpointMatches {
                return endpoint
            }
        }

        return nil
    }

    private func createTestResponse(
        route: String,
        statusCode: Int = 200,
        additionalHeaders: [String: String] = [:]
    ) -> HTTPURLResponse {
        let url = Parra.InternalConstants.parraApiRoot.appendingPathComponent(route)

        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [:].merging(additionalHeaders) { (_, new) in new }
        )!
    }
}
