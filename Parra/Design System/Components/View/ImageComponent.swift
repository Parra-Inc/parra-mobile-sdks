//
//  ImageComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageComponent: ImageComponentType {
    // MARK: - Lifecycle

    init(
        content: ImageContent,
        attributes: ImageAttributes
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: ImageContent
    let attributes: ImageAttributes

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let primaryColor = themeObserver.theme.palette.primary.toParraColor()

        let image = switch content {
        case .resource(let name, let templateRenderingMode):
            Image(name)
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
            .opacity(attributes.opacity ?? 1.0)
            .foregroundStyle(
                attributes.tint ?? primaryColor
            )
            .applyFrame(attributes.frame)
            .padding(attributes.padding ?? .zero)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: themeObserver.theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .strokeBorder(
                    attributes.borderColor ?? primaryColor,
                    lineWidth: attributes.borderWidth ?? 0
                )
            )
            .applyBackground(attributes.background)
            .applyCornerRadii(
                size: attributes.cornerRadius,
                from: themeObserver.theme
            )
    }
}
