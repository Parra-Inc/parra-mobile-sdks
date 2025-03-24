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
        if let preferredThumbnailSize,
           let (thumbUrl, thumbSize) = imageAsset.thumbnailUrl(
               for: preferredThumbnailSize
           )
        {
            self.url = thumbUrl
            self.originalSize = _ParraSize(cgSize: thumbSize)
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
