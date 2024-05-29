//
//  ImageButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageButtonComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraImageButtonConfig,
        content: ImageButtonContent,
        style: ImageButtonStyle,
        onPress: @escaping () -> Void
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPress = onPress
    }

    // MARK: - Internal

    let config: ParraImageButtonConfig
    let content: ImageButtonContent
    let style: ImageButtonStyle
    let onPress: () -> Void

    var body: some View {
        Button(action: {
            onPress()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview("Image Button") {
    ParraViewPreview { _ in
        renderImageButtonStorybook()
    }
}
