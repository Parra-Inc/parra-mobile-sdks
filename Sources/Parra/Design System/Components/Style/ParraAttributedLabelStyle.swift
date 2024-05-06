//
//  ParraAttributedLabelStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedLabelStyle: LabelStyle, ParraAttributedStyle {
    // MARK: - Lifecycle

    init(
        content: LabelContent,
        attributes: LabelAttributes,
        theme: ParraTheme,
        isLoading: Bool = false
    ) {
        self.content = content
        self.attributes = attributes
        self.theme = theme
        self.isLoading = isLoading
    }

    // MARK: - Internal

    let content: LabelContent
    let attributes: LabelAttributes
    let theme: ParraTheme
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }

    func withContent(content: LabelContent) -> ParraAttributedLabelStyle {
        return ParraAttributedLabelStyle(
            content: content,
            attributes: attributes,
            theme: theme,
            isLoading: false
        )
    }
}
