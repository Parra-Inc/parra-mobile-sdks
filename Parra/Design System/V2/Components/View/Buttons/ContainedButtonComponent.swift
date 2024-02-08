//
//  ContainedButtonComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ContainedButtonComponent: ButtonComponentType {
    // MARK: Lifecycle

    init(
        config: ButtonConfig,
        content: ButtonContent,
        style: ParraAttributedButtonStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    // MARK: Internal

    let config: ButtonConfig
    let content: ButtonContent
    let style: ParraAttributedButtonStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Button(action: {
            content.onPress?()
        }, label: {
            EmptyView()
        })
        .disabled(content.isDisabled)
        .buttonStyle(style)
        .padding(style.attributes.padding ?? .zero)
        .applyCornerRadii(
            size: style.attributes.cornerRadius,
            from: themeObserver.theme
        )
    }

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

        let defaultBackgroundColor = switch config.style {
        case .primary:
            palette.primary
        case .secondary:
            palette.secondary
        }

        let commonAttributes = defaults.title.withUpdates(
            updates: LabelAttributes(
                cornerRadius: defaults.title.cornerRadius ?? defaults
                    .cornerRadius,
                fontColor: ParraColorSwatch.neutral.shade50,
                // Frame is applied here to adjust width based on config. If users
                // provide overrides for styles in different states, this will need
                // to be re-created.
                frame: .init(maxWidth: config.isMaxWidth ? .infinity : nil)
            )
        )

        let titleAttributes = commonAttributes.withUpdates(
            updates: LabelAttributes(
                // If specific values for these properties weren't provided for
                // the title label in the default state, apply the values provided
                // for the button itself.
                background: commonAttributes.background ?? inputAttributes?
                    .background ?? defaultBackgroundColor.toParraColor()
            )
        )

        // If a pressed/disabled styles are provided, use them outright.
        let pressedTitleAttributes = commonAttributes.withUpdates(
            updates: LabelAttributes(
                background: titleAttributes.background?.opacity(0.8),
                fontColor: titleAttributes.fontColor?.opacity(0.8)
            )
        )

        let disabledTitleAttributes = commonAttributes.withUpdates(
            updates: LabelAttributes(
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
}

#Preview("Contained Button") {
    renderStorybook(for: ContainedButtonComponent.self)
}
