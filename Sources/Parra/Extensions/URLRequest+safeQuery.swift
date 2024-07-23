//
//  URLRequest+safeQuery.swift
//  Parra
//
//  Created by Mick MacCallum on 7/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension URLRequest {
    init(
        with queryItems: [String: String],
        url: URL,
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeout: TimeInterval? = nil
    ) throws {
        guard var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            throw ParraError.generic(
                "Failed to create components for url: \(url)",
                nil
            )
        }

        urlComponents.percentEncodedQueryItems = queryItems
            .asCorrectlyEscapedQueryItems

        guard let urlWithParams = urlComponents.url else {
            throw ParraError.message("Failed to create url with params")
        }

        self.init(
            url: urlWithParams,
            cachePolicy: cachePolicy ?? .useProtocolCachePolicy,
            timeoutInterval: timeout ?? 60.0
        )
    }
}
