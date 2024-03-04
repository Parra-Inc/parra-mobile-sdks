//
//  ParraAttributedImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedImageButtonStyle: ButtonStyle, ParraAttributedStyle {
    let config: ImageButtonConfig
    let content: ImageButtonContent
    let attributes: ImageButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let primaryColor = theme.palette.primary.toParraColor()

        let currentAttributes = if content.isDisabled {
            attributes.imageDisabled ?? attributes.image
        } else if configuration.isPressed {
            attributes.imagePressed ?? attributes.image
        } else {
            attributes.image
        }

        let imageView = switch content.image {
        case .resource(let name, let templateRenderingMode):
            Image(name)
                .renderingMode(templateRenderingMode ?? .original)
        case .name(let name, let bundle, let templateRenderingMode):
            Image(name, bundle: bundle)
                .renderingMode(templateRenderingMode ?? .original)
        case .symbol(let systemName, let symbolRenderingMode):
            Image(systemName: systemName)
                .symbolRenderingMode(
                    symbolRenderingMode
                        ?? (content.isDisabled ? .monochrome : .multicolor)
                )
        case .image(let uIImage, let templateRenderingMode):
            Image(uiImage: uIImage)
                .renderingMode(templateRenderingMode ?? .original)
        }

        imageView
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(currentAttributes.opacity ?? 1.0)
            .foregroundStyle(currentAttributes.tint ?? primaryColor)
            .applyFrame(currentAttributes.frame)
            .padding(currentAttributes.padding ?? .zero)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius
                        .value(for: currentAttributes.cornerRadius)
                )
                .strokeBorder(
                    currentAttributes.borderColor ?? primaryColor,
                    lineWidth: currentAttributes.borderWidth ?? 0
                )
            )
            .applyBackground(currentAttributes.background)
            .applyCornerRadii(
                size: currentAttributes.cornerRadius,
                from: theme
            )
    }
}
