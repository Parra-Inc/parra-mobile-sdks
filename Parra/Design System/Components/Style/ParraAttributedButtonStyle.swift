//
//  ParraAttributedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedTextButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: ButtonConfig
    let content: ButtonContent
    let attributes: TextButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentTitleAttributes = if content.isDisabled {
            attributes.titleDisabled ?? attributes.title
        } else if configuration.isPressed {
            attributes.titlePressed ?? attributes.title
        } else {
            attributes.title
        }

        switch content.type {
        case .text(let labelContent):
            LabelComponent(
                content: labelContent,
                style: ParraAttributedLabelStyle(
                    content: labelContent,
                    attributes: currentTitleAttributes,
                    theme: theme
                )
            )
        case .image(let imageContent):
            renderImage(
                content: imageContent,
                tintColor: currentTitleAttributes.fontColor
            )
        }
    }

    // MARK: - Private

    @ViewBuilder
    private func renderImage(
        content: ImageContent,
        tintColor: Color?
    ) -> some View {
        let (width, height): (CGFloat, CGFloat) = switch config.size {
        case .small:
            (22, 22)
        case .medium:
            (36, 36)
        case .large:
            (48, 48)
        }

        let imageView = switch content {
        case .resource(let name, let templateRenderingMode):
            Image(name)
                .renderingMode(templateRenderingMode)
        case .name(let name, let bundle, let templateRenderingMode):
            Image(name, bundle: bundle)
                .renderingMode(templateRenderingMode)
        case .symbol(let systemName, let symbolRenderingMode):
            Image(systemName: systemName)
                .symbolRenderingMode(symbolRenderingMode)
        case .image(let uIImage, let templateRenderingMode):
            Image(uiImage: uIImage)
                .renderingMode(templateRenderingMode)
        }

        imageView
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(tintColor ?? .clear)
            .frame(
                width: width,
                height: height
            )
            .padding(attributes.padding ?? .zero)
            .applyBackground(attributes.background)
            .applyCornerRadii(size: attributes.cornerRadius, from: theme)
    }
}
