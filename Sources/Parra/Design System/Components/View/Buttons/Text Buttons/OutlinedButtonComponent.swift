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
        style: OutlinedButtonStyle,
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
    let style: OutlinedButtonStyle
    let onPress: () -> Void

    var body: some View {
        Button(
            action: onPress
        ) {
            EmptyView()
        }
        .disabled(content.isDisabled)
        .buttonStyle(style)
    }
}

#Preview("Outlined Button") {
    ParraViewPreview { _ in
        renderStorybook(for: OutlinedButtonComponent.self)
    }
}
