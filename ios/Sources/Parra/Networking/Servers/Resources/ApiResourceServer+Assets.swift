//
//  ApiResourceServer+Assets.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

private let logger = Logger()

extension ApiResourceServer {
    func fetchAsset(with url: URL) async throws -> UIImage? {
        logger.trace("Fetching asset", [
            "url": url.absoluteString
        ])

        let request = try request(for: url)

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: nil
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }

        defer {
            logger.trace("Caching asset", [
                "url": url.absoluteString
            ])

            let cacheResponse = CachedURLResponse(
                response: response,
                data: data,
                storagePolicy: .allowed
            )

            configuration.urlSession.configuration.urlCache?
                .storeCachedResponse(
                    cacheResponse,
                    for: request
                )
        }

        if httpResponse.statusCode < 300 {
            logger.trace("Successfully retreived image for asset", [
                "url": url.absoluteString
            ])

            return UIImage(data: data)
        }

        logger.warn("Failed to download image for asset", [
            "url": url.absoluteString
        ])

        return nil
    }

    func fetchAsset(asset: ParraImageAsset) async throws -> UIImage? {
        logger.trace("Fetching asset: \(asset.id)", [
            "url": asset.url
        ])

        return try await fetchAsset(with: asset.url)
    }

    func isAssetCached(with url: URL) -> Bool {
        guard let cache = configuration.urlSession.configuration.urlCache else {
            logger.trace("Cache is missing")

            return false
        }

        guard let request = try? request(for: url),
              let cachedResponse = cache.cachedResponse(for: request) else
        {
            logger.trace("Cache miss for asset", [
                "url": url.absoluteString
            ])

            return false
        }

        guard cachedResponse.storagePolicy != .notAllowed else {
            logger.trace("Storage policy disallowed for asset", [
                "url": url.absoluteString
            ])

            return false
        }

        logger.trace("Cache hit for asset", [
            "url": url.absoluteString
        ])

        return true
    }

    func isAssetCached(asset: ParraImageAsset) -> Bool {
        logger.trace("Checking if asset is cached: \(asset.id)")

        return isAssetCached(with: asset.url)
    }

    private func request(for url: URL) throws -> URLRequest {
        var request = try URLRequest(
            with: [:],
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeout: 10.0
        )
        request.httpMethod = HttpMethod.get.rawValue

        return request
    }
}
