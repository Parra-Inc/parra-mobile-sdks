//
//  ImageButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageButtonComponent: ImageButtonComponentType {
    // MARK: - Lifecycle

    init(
        config: ImageButtonConfig,
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

    let config: ImageButtonConfig
    let content: ImageButtonContent
    let style: ImageButtonStyle
    let onPress: () -> Void

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Button(action: {
            onPress()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
    }
}

#Preview("Image Button") {
    ParraViewPreview { _ in
        renderImageButtonStorybook()
    }
}
