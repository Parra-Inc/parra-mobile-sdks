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
    func performBulkAssetCachingRequest(assets: [Asset]) async {
        logger
            .trace(
                "Performing bulk asset caching request for \(assets.count) asset(s)"
            )

        _ = await assets.asyncMap { asset in
            await cacheAsset(asset)
        }
    }

    func cacheAsset(
        _ asset: Asset
    ) async {
        do {
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
        _ assetStub: ImageAssetStub
    ) async {
        let asset = Asset(
            id: assetStub.id,
            url: assetStub.url
        )

        await cacheAsset(asset)
    }
}
