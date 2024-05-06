//
//  ParraAttributedEmptyStateStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedEmptyStateStyle: ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
        config: EmptyStateConfig,
        content: EmptyStateContent,
        attributes: EmptyStateAttributes,
        theme: ParraTheme
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.theme = theme

        self.titleStyle = ParraAttributedLabelStyle(
            content: content.title,
            attributes: attributes.title,
            theme: theme
        )

        if let subtitleContent = content.subtitle {
            self.subtitleStyle = ParraAttributedLabelStyle(
                content: subtitleContent,
                attributes: attributes.subtitle,
                theme: theme
            )
        } else {
            self.subtitleStyle = nil
        }

        self.iconAttributes = attributes.icon
    }

    // MARK: - Internal

    let config: EmptyStateConfig
    let content: EmptyStateContent
    let attributes: EmptyStateAttributes
    let theme: ParraTheme

    let titleStyle: ParraAttributedLabelStyle
    let subtitleStyle: ParraAttributedLabelStyle?
    let iconAttributes: ParraAttributes.Image?
}
