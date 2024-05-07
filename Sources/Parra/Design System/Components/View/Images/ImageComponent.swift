//
//  ImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageComponent: ImageComponentType {
    // MARK: - Internal

    let content: ParraImageContent
    let attributes: ParraAttributes.Image

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

    var body: some View {
        baseImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .applyImageAttributes(
                attributes,
                using: themeObserver.theme
            )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
