//
//  OutlinedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OutlinedButtonComponent: TextButtonComponentType {
    // MARK: - Lifecycle

    init(
        config: TextButtonConfig,
        content: TextButtonContent,
        style: ParraAttributedTextButtonStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent
    let style: ParraAttributedTextButtonStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let _ = print("Rendering Outlined button")
        Button(action: {
            content.onPress?()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
        .padding(style.attributes.padding ?? .zero)
        .applyCornerRadii(
            size: style.attributes.cornerRadius,
            from: themeObserver.theme
        )
    }
}

#Preview("Outlined Button") {
    ParraThemedPreviewWrapper {
        renderStorybook(for: OutlinedButtonComponent.self)
    }
}
