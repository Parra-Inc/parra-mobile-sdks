//
//  MockURLSession.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra
import XCTest

typealias DataTaskResponse = (
    data: Data?,
    response: URLResponse?,
    error: Error?
)
typealias DataTaskResolver = (_ request: URLRequest) -> DataTaskResponse

class MockURLSession: URLSessionType {
    // MARK: - Lifecycle

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    // MARK: - Internal

    var configuration: URLSessionConfiguration = .default

    func resetExpectations() {
        expectedEndpoints.removeAll()
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
        // Changing this value may break time sensitive tests.
        try await Task.sleep(for: 0.1)

        let (data, response, error) = resolve(request)

        if let error {
            throw error
        }

        return (data!, response!)
    }

    func expectInvocation(
        of endpoint: ParraEndpoint,
        times: Int = 1,
        matching predicate: ((URLRequest) throws -> Bool)? = nil,
        toReturn responder: (() throws -> (Int, Data))? = nil
    ) -> XCTestExpectation {
        let expectation = testCase.expectation(
            description: "Expected endpoint \(endpoint.slug) to be called"
        )
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = times

        expectedEndpoints[endpoint.slug] = (
            expectation,
            times,
            predicate,
            responder
        )

        return expectation
    }

    func expectInvocation(
        of endpoint: ParraEndpoint,
        times: Int = 1,
        matching predicate: ((URLRequest) throws -> Bool)? = nil,
        toReturn value: (Int, some Codable)
    ) throws -> XCTestExpectation {
        let (status, data) = value
        let encodedData = try JSONEncoder.parraEncoder.encode(data)

        return expectInvocation(
            of: endpoint,
            times: times,
            matching: predicate
        ) {
            return (status, encodedData)
        }
    }

    // MARK: - Private

    private let testCase: XCTestCase

    private var expectedEndpoints = [
        String: (
            expectation: XCTestExpectation,
            times: Int,
            predicate: ((URLRequest) throws -> Bool)?,
            returning: (() throws -> (Int, Data))?
        )
    ]()

    private func resolve(_ request: URLRequest) -> DataTaskResponse {
        if let endpoint = matchingEndpoint(for: request) {
            // The request is to the Parra API.
            return resolveParraApiRequest(request, endpoint: endpoint)
        } else {
            // The request is to a 3rd party.
            return resolve3rdPartyApiRequest(request)
        }
    }

    private func resolve3rdPartyApiRequest(
        _ request: URLRequest
    ) -> DataTaskResponse {
        let url = request.url!
        let absoluteUrl = url.absoluteString

        do {
            let responseStatus = 200
            let responseData = try ParraEndpoint.getMock3rdPartyResponseData(
                for: url,
                status: responseStatus
            )

            return try handleRequestResolution(
                request: request,
                status: responseStatus,
                slug: absoluteUrl,
                route: absoluteUrl,
                data: responseData
            )
        } catch {
            return handleRequestResolutionError(
                error,
                request: request,
                route: absoluteUrl
            )
        }
    }

    private func resolveParraApiRequest(
        _ request: URLRequest,
        endpoint: ParraEndpoint
    ) -> DataTaskResponse {
        do {
            let responseStatus = 200
            let responseData = try endpoint.getMockResponseData(
                for: responseStatus
            )

            return try handleRequestResolution(
                request: request,
                status: responseStatus,
                slug: endpoint.slug,
                route: endpoint.route,
                data: responseData
            )

        } catch {
            return handleRequestResolutionError(
                error,
                request: request,
                route: endpoint.route
            )
        }
    }

    private func handleRequestResolution(
        request: URLRequest,
        status: Int,
        slug: String,
        route: String,
        data: Data
    ) throws -> DataTaskResponse {
        var responseStatus = status
        var responseData = data
        // We were able to get response data for this mocked object. Fulfill
        // the expectation. Possibly expand this in the future to allow
        // setting expected status codes.

        if let endpointExpectation = expectedEndpoints[slug] {
            // If there is a predicate function, fulfill if it returns true
            // If there isn't a predicate function, fulfill.
            let predicateResult = try endpointExpectation
                .predicate?(request) ?? true

            if predicateResult {
                endpointExpectation.expectation.fulfill()
            } else {
                throw ParraError.generic(
                    "Predicate failed to mock of route: \(slug)",
                    nil
                )
            }

            if let response = endpointExpectation.returning {
                let (status, data) = try response()

                responseStatus = status
                responseData = data
            }

            if endpointExpectation.times <= 1 {
                expectedEndpoints.removeValue(forKey: slug)
            } else {
                expectedEndpoints[slug] = (
                    endpointExpectation.expectation,
                    endpointExpectation.times - 1,
                    endpointExpectation.predicate,
                    endpointExpectation.returning
                )
            }
        }

        testCase.addJsonAttachment(
            data: responseData,
            name: "Response object",
            lifetime: .keepAlways
        )

        return (
            responseData,
            createTestResponse(
                route: route,
                statusCode: responseStatus
            ),
            nil
        )
    }

    private func handleRequestResolutionError(
        _ error: Error,
        request: URLRequest,
        route: String
    ) -> DataTaskResponse {
        if let body = request.httpBody {
            testCase.addJsonAttachment(
                data: body,
                name: "Request body"
            )
        }

        if let headers = request.allHTTPHeaderFields {
            try? testCase.addJsonAttachment(
                value: headers,
                name: "Request headers"
            )
        }

        return (
            nil,
            createTestResponse(
                route: route,
                statusCode: 400
            ),
            error
        )
    }

    /// Attempts to find a ParraEndpoint case that most closely matches the
    /// request url. This is done by iterating over the path components of both
    /// the request url, and the expected url components of each endpoint and
    /// comparing non-variable components.
    private func matchingEndpoint(for request: URLRequest) -> ParraEndpoint? {
        guard let url = request.url else {
            return nil
        }

        let apiRoot = ParraInternal.Constants.parraApiRoot
        let urlString = url.absoluteString
            .trimmingCharacters(in: .punctuationCharacters)
        let rootString = apiRoot.absoluteString

        guard urlString.starts(with: rootString) else {
            return nil
        }

        let suffix = urlString.dropFirst(rootString.count)
        let remainingComponents = suffix.split(separator: "/")

        for endpoint in ParraEndpoint.allCases {
            let slugComponents = endpoint.slug.split(separator: "/")

            // If they don't have the same path component count, it's
            // an easy no-match.
            guard remainingComponents.count == slugComponents.count else {
                continue
            }

            var endpointMatches = true
            for (index, slugComponent) in slugComponents.enumerated() {
                // Slug components starting with : are used to denote a
                // variable path component and do not need to be compared.
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
        let url = ParraInternal.Constants.parraApiRoot
            .appendingPathComponent(route)

        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [:].merging(additionalHeaders) { _, new in new }
        )!
    }
}
