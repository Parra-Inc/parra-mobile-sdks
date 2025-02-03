//
//  API+assets.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

private let logger = Logger()

extension API {
    func performBulkAssetCachingRequest(assets: [ParraImageAsset]) async {
        logger
            .trace(
                "Performing bulk asset caching request for \(assets.count) asset(s)"
            )

        _ = await assets.asyncMap { asset in
            await cacheAsset(asset)
        }
    }

    func performBulkAssetCachingRequest(assetUrls: [URL]) async {
        logger
            .trace(
                "Performing bulk asset caching request for \(assetUrls.count) asset(s)"
            )

        _ = await assetUrls.asyncMap { url in
            await cacheAsset(with: url)
        }
    }

    func cacheAsset(
        _ asset: ParraImageAsset
    ) async {
        do {
            if await apiResourceServer.isAssetCached(asset: asset) {
                logger.debug("Skipping caching asset. Already cached.", [
                    "id": asset.id,
                    "url": asset.url.absoluteString
                ])

                return
            }

            _ = try await apiResourceServer.fetchAsset(
                asset: asset
            )
        } catch {
            logger.error("Failed to cache asset", [
                "id": asset.id,
                "url": asset.url.absoluteString
            ])
        }
    }

    func cacheAsset(
        with url: URL
    ) async {
        do {
            if await apiResourceServer.isAssetCached(with: url) {
                logger.debug("Skipping caching asset. Already cached.", [
                    "url": url.absoluteString
                ])

                return
            }

            _ = try await apiResourceServer.fetchAsset(with: url)
        } catch {
            logger.error("Failed to cache asset", [
                "url": url.absoluteString
            ])
        }
    }
}
