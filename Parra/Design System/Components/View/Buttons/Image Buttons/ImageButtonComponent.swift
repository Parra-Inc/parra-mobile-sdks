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
        style: ParraAttributedImageButtonStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: - Internal

    let config: ImageButtonConfig
    let content: ImageButtonContent
    let style: ParraAttributedImageButtonStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Button(action: {
            content.onPress?()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
    }
}

#Preview("Image Button") {
    ParraThemedPreviewWrapper {
        renderImageButtonStorybook()
    }
}
