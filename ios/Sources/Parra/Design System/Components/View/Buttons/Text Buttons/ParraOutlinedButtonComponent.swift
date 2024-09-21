//
//  ParraOutlinedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraOutlinedButtonComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraTextButtonConfig,
        content: ParraTextButtonContent,
        style: ParraOutlinedButtonStyle,
        onPress: @escaping () -> Void
    ) {
        self.config = config
        self.content = content
        self.style = style
        self.onPress = onPress
    }

    // MARK: - Public

    public let config: ParraTextButtonConfig
    public let content: ParraTextButtonContent
    public let style: ParraOutlinedButtonStyle
    public let onPress: () -> Void

    public var body: some View {
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
        renderStorybook(for: ParraOutlinedButtonComponent.self)
    }
}
