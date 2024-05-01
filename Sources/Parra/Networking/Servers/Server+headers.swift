//
//  Server+headers.swift
//  Parra
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Server")

extension Server {
    func addHeaders(
        to request: inout URLRequest,
        endpoint: ParraEndpoint,
        for appState: ParraAppState,
        with headerFactory: HeaderFactory
    ) {
        request.setValue(for: .accept(.applicationJson))

        if endpoint.method.allowsBody {
            request.setValue(for: .contentType(.applicationJson))
        }

        // Important to be called for every HTTP request. All requests must
        // include certain tracking headers, but only specific endpoints will be
        // sent more extensive context about the device.
        addTrackingHeaders(
            toRequest: &request,
            for: endpoint,
            with: headerFactory
        )

        let headers = request.allHTTPHeaderFields ?? [:]

        logger.trace(
            "Finished attaching request headers for endpoint: \(endpoint.displayName)",
            headers
        )
    }

    private func addTrackingHeaders(
        toRequest request: inout URLRequest,
        for endpoint: ParraEndpoint,
        with headerFactory: HeaderFactory
    ) {
        let headers = if endpoint.isTrackingEnabled {
            headerFactory.trackingHeaderDictionary
        } else {
            headerFactory.commonHeaderDictionary
        }

        logger
            .trace(
                "Adding extra tracking headers to tracking enabled endpoint: \(endpoint.displayName)"
            )

        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
}