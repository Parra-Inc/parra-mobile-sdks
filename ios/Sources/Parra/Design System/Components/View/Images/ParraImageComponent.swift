//
//  ParraImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraImageConfig,
        content: ParraImageContent,
        attributes: ParraAttributes.Image
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Public

    public let config: ParraImageConfig
    public let content: ParraImageContent
    public let attributes: ParraAttributes.Image

    public var body: some View {
        baseImage
            .resizable()
            .aspectRatio(
                config.aspectRatio,
                contentMode: config.contentMode
            )
            .applyImageAttributes(
                attributes,
                using: parraTheme
            )
    }

    // MARK: - Internal

    @ViewBuilder var baseImage: Image {
        let image = switch content {
        case .resource(let name, let bundle, let templateRenderingMode):
            Image(name, bundle: bundle)
                .renderingMode(templateRenderingMode ?? .original)
        case .name(let name, let bundle, let templateRenderingMode):
            Image(name, bundle: bundle)
                .renderingMode(templateRenderingMode ?? .original)
        case .symbol(let systemName, let symbolRenderingMode):
            Image(systemName: systemName)
                .symbolRenderingMode(symbolRenderingMode ?? .monochrome)
        case .image(let uIImage, let templateRenderingMode):
            Image(uiImage: uIImage)
                .renderingMode(templateRenderingMode ?? .original)
        }

        image
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
