//
//  OutlinedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OutlinedButtonComponent: ButtonComponentType {
    let config: ButtonConfig
    let content: ButtonContent
    let style: ParraAttributedButtonStyle

    static func applyStandardCustomizations(
        onto inputAttributes: ButtonAttributes?,
        theme: ParraTheme,
        config: ButtonConfig
    ) -> ButtonAttributes {
        let palette = theme.palette
        let defaults = ButtonAttributes.defaultAttributes(
            for: theme,
            with: config
        ).withUpdates(updates: inputAttributes)

        let mainColor = switch config.style {
        case .primary:
            palette.primary
        case .secondary:
            palette.secondary
        }

        let titleAttributes = defaults.title.withUpdates(
            updates: LabelAttributes(
                // If specific values for these properties weren't provided for
                // the title label in the default state, apply the values provided
                // for the button itself.
                background: defaults.title.background ?? defaults.background,
                cornerRadius: defaults.title.cornerRadius ?? defaults.cornerRadius,
                fontColor: mainColor,
                // Frame is applied here to adjust width based on config. If users
                // provide overrides for styles in different states, this will need
                // to be re-created.
                frame: .init(maxWidth: config.isMaxWidth ? .infinity : nil),
                borderWidth: 1
            )
        )

        // If a pressed/disabled styles are provided, use them outright.
        let pressedTitleAttributes = (defaults.titlePressed ?? titleAttributes).withUpdates(
            updates: .init(
                background: titleAttributes.background?.opacity(0.6),
                fontColor: titleAttributes.fontColor?.opacity(0.6)
            )
        )

        let disabledTitleAttributes = (defaults.titleDisabled ?? titleAttributes).withUpdates(
            updates: .init(
                background: titleAttributes.background?.opacity(0.6),
                fontColor: titleAttributes.fontColor?.opacity(0.6)
            )
        )

        return defaults.withUpdates(
            updates: ButtonAttributes(
                title: titleAttributes,
                titleDisabled: disabledTitleAttributes,
                titlePressed: pressedTitleAttributes
            )
        )
    }

    var body: some View {
        Button(action: {
            content.onPress?()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
        .padding(style.attributes.padding ?? .zero)
        .applyCornerRadii(style.attributes.cornerRadius)
    }
}

#Preview("Outlined Button") {
    renderStorybook(for: OutlinedButtonComponent.self)
}