//
//  ComponentFactory+Image.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildImage(
        config: ParraImageConfig = ParraImageConfig(),
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image? = nil
    ) -> some View {
        let attributes = attributeProvider.imageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        ImageComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }

    @ViewBuilder
    func buildAsyncImage(
        config: ParraImageConfig? = nil,
        content: AsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage? = nil
    ) -> some View {
        let attributes = attributeProvider.asyncImageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        // If a config wasn't provided, create a default one based on the
        // image's expected aspect ratio.
        let finalConfig: ParraImageConfig = if let config {
            config
        } else {
            if let originalSize = content.originalSize {
                ParraImageConfig(
                    aspectRatio: originalSize.height / originalSize.width
                )
            } else {
                ParraImageConfig()
            }
        }

        AsyncImageComponent(
            config: finalConfig,
            content: content,
            attributes: attributes
        )
    }
}
