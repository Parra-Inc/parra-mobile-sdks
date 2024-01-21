//
//  OutlinedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OutlinedButtonComponent: Component {
    typealias Config = ButtonConfig
    typealias Content = ButtonContent
    typealias Style = ButtonStyle

    var config: Config
    var content: Content
    var style: Style

    static func defaultStyleInContext(
        of theme: ParraTheme,
        with config: Config
    ) -> ButtonStyle {
        let palette = theme.palette
        let defaults = ButtonStyle.defaultStyles(
            for: theme,
            with: config
        )

        let mainColor = switch config.style {
        case .primary:
            palette.primary
        case .secondary:
            palette.secondary
        }

        return defaults.withUpdates(
            updates: .init(
                title: defaults.title.withUpdates(
                    updates: .init(
                        fontColor: mainColor,
                        borderWidth: 1
                    )
                )
            )
        )
    }

    private var buttonStyle: StatefulButtonStyle {
        let titleStyle = style.title.withUpdates(
            updates: TextStyle(
                // If specific values for these properties weren't provided for
                // the title label in the default state, apply the values provided
                // for the button itself.
                background: style.title.background ?? style.background,
                cornerRadius: style.title.cornerRadius ?? style.cornerRadius,
                // Frame is applied here to adjust width based on config. If users
                // provide overrides for styles in different states, this will need
                // to be re-created.
                frame: .init(maxWidth: config.isMaxWidth ? .infinity : nil)
            )
        )

        // If a pressed/disabled styles are provided, use them outright.
        let pressedTitleStyle = style.titlePressed ?? titleStyle.withUpdates(
            updates: .init(
                background: titleStyle.background?.opacity(0.6),
                fontColor: titleStyle.fontColor?.opacity(0.6)
            )
        )

        let disabledTitleStyle = style.titleDisabled ?? titleStyle.withUpdates(
            updates: .init(
                background: titleStyle.background?.opacity(0.6),
                fontColor: titleStyle.fontColor?.opacity(0.6)
            )
        )

        return StatefulButtonStyle(
            config: config,
            content: content,
            titleStyle: titleStyle,
            pressedTitleStyle: pressedTitleStyle,
            disabledTitleStyle: disabledTitleStyle
        )
    }

    var body: some View {
        Button(action: {
            content.onPress?()
        }, label: {}) // awkward, but label is created in button style.
        .disabled(content.isDisabled)
        .buttonStyle(buttonStyle)
        .padding(style.padding ?? .zero)
        .applyCornerRadii(style.cornerRadius)
    }
}

#Preview("Outlined Button") {
    renderStorybook(for: OutlinedButtonComponent.self)
}
