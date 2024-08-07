//
//  PlainButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PlainButtonComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraTextButtonConfig,
        content: ParraTextButtonContent,
        style: PlainButtonStyle,
        onPress: @escaping () -> Void
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPress = onPress
    }

    // MARK: - Internal

    let config: ParraTextButtonConfig
    let content: ParraTextButtonContent
    let style: PlainButtonStyle
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

#Preview("Plain Button") {
    ParraViewPreview { _ in
        renderStorybook(for: PlainButtonComponent.self)
    }
}
