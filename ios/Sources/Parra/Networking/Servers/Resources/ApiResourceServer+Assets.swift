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
    func fetchAsset(asset: ParraImageAsset) async throws -> UIImage? {
        logger.trace("Fetching asset: \(asset.id)", [
            "url": asset.url
        ])

        let request = try request(for: asset)

        let (data, response) = try await configuration.urlSession
            .dataForRequest(
                for: request,
                delegate: nil
            )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }

        defer {
            logger.trace("Caching asset: \(asset.id)")

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
            logger.trace("Successfully retreived image for asset: \(asset.id)")

            return UIImage(data: data)
        }

        logger.warn("Failed to download image for asset: \(asset.id)")

        return nil
    }

    func isAssetCached(asset: ParraImageAsset) -> Bool {
        logger.trace("Checking if asset is cached: \(asset.id)")

        guard let cache = configuration.urlSession.configuration.urlCache else {
            logger.trace("Cache is missing")

            return false
        }

        guard let request = try? request(for: asset),
              let cachedResponse = cache.cachedResponse(for: request) else
        {
            logger.trace("Cache miss for asset: \(asset.id)")
            return false
        }

        guard cachedResponse.storagePolicy != .notAllowed else {
            logger.trace("Storage policy disallowed for asset: \(asset.id)")

            return false
        }

        logger.trace("Cache hit for asset: \(asset.id)")

        return true
    }

    private func request(for asset: ParraImageAsset) throws -> URLRequest {
        var request = try URLRequest(
            with: [:],
            url: asset.url,
            cachePolicy: .returnCacheDataElseLoad,
            timeout: 10.0
        )
        request.httpMethod = HttpMethod.get.rawValue

        return request
    }
}
