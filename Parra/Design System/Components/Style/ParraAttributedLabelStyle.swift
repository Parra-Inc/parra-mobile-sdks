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

        HStack {
            Text(content.text)
                .frame(
                    minWidth: attributes.frame?.minWidth,
                    idealWidth: attributes.frame?.idealWidth,
                    maxWidth: attributes.frame?.maxWidth,
                    minHeight: attributes.frame?.minHeight,
                    idealHeight: attributes.frame?.idealHeight,
                    maxHeight: attributes.frame?.maxHeight,
                    alignment: attributes.frame?.alignment ?? .center
                )
                .foregroundStyle(fontColor)
                .padding(attributes.padding ?? .zero)
                .overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: theme.cornerRadius
                            .value(for: attributes.cornerRadius)
                    )
                    .stroke(
                        fontColor,
                        lineWidth: attributes.borderWidth ?? 0
                    )
                )
                .applyBackground(attributes.background)
                .applyCornerRadii(size: attributes.cornerRadius, from: theme)
                .font(attributes.font)
                .fontDesign(attributes.fontDesign)
                .fontWeight(attributes.fontWeight)
                .fontWidth(attributes.fontWidth)
        }
    }

    func withContent(content: LabelContent) -> ParraAttributedLabelStyle {
        return ParraAttributedLabelStyle(
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
