//
//  ContainedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ContainedButtonComponent: TextButtonComponentType {
    // MARK: - Lifecycle

    init(
        config: TextButtonConfig,
        content: TextButtonContent,
        style: ContainedButtonStyle,
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
    let style: ContainedButtonStyle
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

#Preview("Contained Button") {
    ParraViewPreview { _ in
        renderStorybook(for: ContainedButtonComponent.self)
    }
}
