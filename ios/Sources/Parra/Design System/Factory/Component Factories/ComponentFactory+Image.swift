//
//  ComponentFactory+Image.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    func buildImage(
        config: ParraImageConfig = ParraImageConfig(),
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image? = nil
    ) -> ParraImageComponent {
        let attributes = attributeProvider.imageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraImageComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }

    func buildAsyncImage(
        config: ParraAsyncImageConfig? = nil,
        content: ParraAsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage? = nil
    ) -> ParraAsyncImageComponent {
        let attributes = attributeProvider.asyncImageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        // If a config wasn't provided, create a default one based on the
        // image's expected aspect ratio.
        let finalConfig: ParraAsyncImageConfig = if let config {
            if config.aspectRatio == nil {
                ParraAsyncImageConfig(
                    aspectRatio: content.originalSize.width / content.originalSize.height,
                    contentMode: config.contentMode,
                    blurContent: config.blurContent,
                    showBlurHash: config.showBlurHash,
                    showFailureIndicator: config.showFailureIndicator,
                    showLoadingIndicator: config.showLoadingIndicator,
                    cachePolicy: config.cachePolicy,
                    timeoutInterval: config.timeoutInterval
                )
            } else {
                config
            }
        } else {
            ParraAsyncImageConfig(
                aspectRatio: content.originalSize.width / content.originalSize.height
            )
        }

        return ParraAsyncImageComponent(
            config: finalConfig,
            content: content,
            attributes: attributes
        )
    }
}
