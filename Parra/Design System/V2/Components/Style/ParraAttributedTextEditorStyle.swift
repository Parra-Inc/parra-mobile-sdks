//
//  ParraAttributedTextEditorStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ParraAttributedTextEditorStyle: TextEditorStyle, ParraAttributedStyle {
    internal let config: TextEditorConfig
    internal let content: TextEditorContent
    internal let attributes: TextEditorAttributes
    internal let theme: ParraTheme

    internal let titleStyle: ParraAttributedLabelStyle?
    internal let helperStyle: ParraAttributedLabelStyle?

    init(
        config: TextEditorConfig,
        content: TextEditorContent,
        attributes: TextEditorAttributes,
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
    }

    @ViewBuilder
    internal func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}
