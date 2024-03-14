//
//  PlainButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PlainButtonComponent: TextButtonComponentType {
    // MARK: - Lifecycle

    init(
        config: TextButtonConfig,
        content: TextButtonContent,
        style: ParraAttributedTextButtonStyle,
        onPress: @escaping () -> Void
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPress = onPress
    }

    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent
    let style: ParraAttributedTextButtonStyle
    let onPress: () -> Void

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Button(action: onPress, label: {
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

#Preview("Plain Button") {
    ParraViewPreview { _ in
        renderStorybook(for: PlainButtonComponent.self)
    }
}
