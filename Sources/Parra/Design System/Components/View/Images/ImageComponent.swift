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

    let content: ImageContent
    let attributes: ImageAttributes

    var body: some View {
        let primaryColor = themeObserver.theme.palette.primary.toParraColor()

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
            .resizable()
            .aspectRatio(contentMode: .fit)
            .applyOpacity(attributes.opacity)
            .foregroundStyle(
                attributes.tint ?? primaryColor
            )
            .applyFrame(attributes.frame)
            .padding(attributes.padding ?? .zero)
            .applyBorder(
                borderColor: attributes.borderColor ?? primaryColor,
                borderWidth: attributes.borderWidth,
                cornerRadius: attributes.cornerRadius,
                from: themeObserver.theme
            )
            .applyBackground(attributes.background)
            .applyCornerRadii(
                size: attributes.cornerRadius,
                from: themeObserver.theme
            )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
