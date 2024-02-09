//
//  ParraAttributedMenuStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedMenuStyle: MenuStyle, ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
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
                content: title,
                attributes: attributes.title,
                theme: theme
            )
        } else {
            nil
        }
        self.helperStyle = if let helper = content.helper {
            ParraAttributedLabelStyle(
                content: helper,
                attributes: attributes.helper,
                theme: theme
            )
        } else {
            nil
        }

        self.menuOptionStyle = ParraAttributedLabelStyle(
            content: .init(text: ""), // will be overridden elsewhere
            attributes: attributes.menuItem,
            theme: theme
        )

        self.menuOptionSelectedStyle = ParraAttributedLabelStyle(
            content: .init(text: ""), // will be overridden elsewhere
            attributes: attributes.menuItemSelected,
            theme: theme
        )
    }

    // MARK: - Internal

    let config: MenuConfig
    let content: MenuContent
    let attributes: MenuAttributes
    let theme: ParraTheme

    let titleStyle: ParraAttributedLabelStyle?
    let helperStyle: ParraAttributedLabelStyle?

    let menuOptionStyle: ParraAttributedLabelStyle
    let menuOptionSelectedStyle: ParraAttributedLabelStyle

    func makeBody(configuration: Configuration) -> some View {
        let tint = attributes.tint ?? theme.palette.secondaryText.toParraColor()

        Menu(configuration)
            .menuOrder(attributes.sortOrder)
            .tint(tint)
            .applyCornerRadii(size: attributes.cornerRadius, from: theme)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius
                        .value(for: attributes.cornerRadius)
                )
                .stroke(
                    tint,
                    lineWidth: attributes.borderWidth
                )
            )
    }

    func withAttributes(attributes: MenuAttributes)
        -> ParraAttributedMenuStyle
    {
        return ParraAttributedMenuStyle(
            config: config,
            content: content,
            attributes: attributes,
            theme: theme
        )
    }
}
