//
//  ParraImageButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageButtonComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraImageButtonConfig,
        content: ParraImageButtonContent,
        style: ParraImageButtonStyle,
        onPress: @escaping () -> Void
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPress = onPress
    }

    // MARK: - Public

    public let config: ParraImageButtonConfig
    public let content: ParraImageButtonContent
    public let style: ParraImageButtonStyle
    public let onPress: () -> Void

    public var body: some View {
        Button(action: {
            onPress()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled || content.isLoading)
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
