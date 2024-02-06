//
//  ParraAttributedMenuStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ParraAttributedMenuStyle: MenuStyle, ParraAttributedStyle {
    internal let config: MenuConfig
    internal let content: MenuContent
    internal let attributes: MenuAttributes
    internal let theme: ParraTheme
    internal let labelStyle: ParraAttributedLabelStyle
    internal let labelWithSelectionStyle: ParraAttributedLabelStyle

    internal init(
        config: MenuConfig,
        content: MenuContent,
        attributes: MenuAttributes,
        theme: ParraTheme
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.theme = theme
        self.labelStyle = ParraAttributedLabelStyle(
            config: config.label,
            content: content.label,
            attributes: attributes.label,
            theme: theme
        )
        self.labelWithSelectionStyle = ParraAttributedLabelStyle(
            config: config.label,
            content: content.label,
            attributes: attributes.labelWithSelection ?? attributes.label,
            theme: theme
        )
    }

    internal func makeBody(configuration: Configuration) -> some View {
        let tint = attributes.tint ?? .accentColor

        Menu(configuration)
            .menuOrder(attributes.sortOrder)
            .tint(tint)
            .padding(attributes.padding ?? .zero)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: attributes.cornerRadius ?? .zero
                )
                .stroke(
                    tint,
                    lineWidth: attributes.borderWidth
                )
            )
            .applyBackground(attributes.background)
            .applyCornerRadii(attributes.cornerRadius)
    }

    internal func withAttributes(attributes: MenuAttributes) -> ParraAttributedMenuStyle {
        return ParraAttributedMenuStyle(
            config: config,
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
