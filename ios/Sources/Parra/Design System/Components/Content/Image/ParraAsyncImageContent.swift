//
//  ParraAsyncImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct ParraAsyncImageContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        _ imageAsset: ParraImageAsset,
        preferredThumbnailSize: ParraImageAssetThumbnailSize? = nil
    ) {
        if let preferredThumbnailSize, let thumbnails = imageAsset.thumbnails {
            let thumb = thumbnails.thumbnail(for: preferredThumbnailSize)

            self.url = thumb.url
            self.originalSize = _ParraSize(cgSize: thumb.size)
        } else {
            self.url = imageAsset.url
            self.originalSize = imageAsset._size
        }

        self.blurHash = imageAsset.blurHash
    }

    public init(
        url: URL,
        blurHash: String? = nil,
        originalSize: CGSize? = nil
    ) {
        self.url = url
        self.blurHash = blurHash
        self.originalSize = _ParraSize(cgSize: originalSize)
    }

    // MARK: - Internal

    let url: URL
    let blurHash: String?
    let originalSize: _ParraSize?
}
