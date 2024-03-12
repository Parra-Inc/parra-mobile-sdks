//
//  ParraAttributedLabelStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedLabelStyle: LabelStyle, ParraAttributedStyle {
    let content: LabelContent
    let attributes: LabelAttributes
    let theme: ParraTheme

    func makeBody(configuration: Configuration) -> some View {
        let fontColor = attributes.fontColor ?? theme.palette.primaryText
            .toParraColor()

        let defaultImageAttributes = ImageAttributes(
            tint: attributes.iconAttributes?.tint ?? fontColor
        )

        let image: (some View)? = if let icon = content.icon {
            ImageComponent(
                content: icon,
                attributes: defaultImageAttributes.withUpdates(
                    updates: attributes.iconAttributes
                )
            )
            // Need to override resizable modifier from general implementation.
            .fixedSize()
        } else {
            nil
        }

        let text = Text(content.text)
            .font(attributes.font)
            .fontDesign(attributes.fontDesign)
            .fontWeight(attributes.fontWeight)
            .fontWidth(attributes.fontWidth)

        HStack(spacing: attributes.padding?.leading ?? 6) {
            switch attributes.layoutDirectionBehavior {
            case .mirrors:
                text
                image
            default:
                image
                text
            }
        }
        .applyFrame(attributes.frame)
        .foregroundStyle(fontColor)
        .padding(attributes.padding ?? .zero)
        .overlay(
            UnevenRoundedRectangle(
                cornerRadii: theme.cornerRadius
                    .value(for: attributes.cornerRadius)
            )
            .strokeBorder(
                attributes.borderColor ?? fontColor,
                lineWidth: attributes.borderWidth ?? 0
            )
        )
        .applyBackground(attributes.background)
        .applyCornerRadii(size: attributes.cornerRadius, from: theme)
    }

    func withContent(content: LabelContent) -> ParraAttributedLabelStyle {
        return ParraAttributedLabelStyle(
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
