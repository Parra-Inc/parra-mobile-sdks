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
    
    internal let titleStyle: ParraAttributedLabelStyle?
    internal let helperStyle: ParraAttributedLabelStyle?

    internal let menuOptionStyle: ParraAttributedLabelStyle
    internal let menuOptionSelectedStyle: ParraAttributedLabelStyle

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
        self.titleStyle = if let title = content.title {
            ParraAttributedLabelStyle(
                config: config.title,
                content: title,
                attributes: attributes.title,
                theme: theme
            )
        } else {
            nil
        }
        self.helperStyle = if let helper = content.helper {
            ParraAttributedLabelStyle(
                config: config.helper,
                content: helper,
                attributes: attributes.helper,
                theme: theme
            )
        } else {
            nil
        }

        self.menuOptionStyle = ParraAttributedLabelStyle(
            config: config.menuOption,
            content: .init(text: ""), // will be overridden elsewhere
            attributes: attributes.menuItem,
            theme: theme
        )

        self.menuOptionSelectedStyle = ParraAttributedLabelStyle(
            config: config.menuOptionSelected,
            content: .init(text: ""), // will be overridden elsewhere
            attributes: attributes.menuItemSelected,
            theme: theme
        )
    }

    internal func makeBody(configuration: Configuration) -> some View {
        let tint = attributes.tint ?? theme.palette.secondaryText.toParraColor()

        Menu(configuration)
            .menuOrder(attributes.sortOrder)
            .tint(tint)
            .applyCornerRadii(size: attributes.cornerRadius, from: theme)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius.value(for: attributes.cornerRadius)
                )
                .stroke(
                    tint,
                    lineWidth: attributes.borderWidth
                )
            )
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
