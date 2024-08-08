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
        content: ParraImageButtonContent,
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
    let content: ParraImageButtonContent
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

    @Environment(\.parraTheme) private var parraTheme
}

#Preview("Image Button") {
    ParraViewPreview { _ in
        renderImageButtonStorybook()
    }
}
