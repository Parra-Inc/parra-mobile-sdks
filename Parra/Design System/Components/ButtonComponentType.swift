//
//  ButtonComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ButtonComponentType: View {
    var config: ButtonConfig { get }
    var content: ButtonContent { get }
    var style: ParraAttributedButtonStyle { get }

    init(
        config: ButtonConfig,
        content: ButtonContent,
        style: ParraAttributedButtonStyle
    )
}

extension ButtonComponentType {
    static func applyStandardCustomizations(
        onto inputAttributes: ButtonAttributes?,
        theme: ParraTheme,
        config: ButtonConfig,
        for buttonType: (some ButtonComponentType).Type
    ) -> ButtonAttributes {
        let palette = theme.palette
        let defaults = ButtonAttributes.defaultAttributes(
            for: theme,
            with: config
        ).withUpdates(updates: inputAttributes)

        let mainColor = switch config.style {
        case .primary:
            palette.primary.toParraColor()
        case .secondary:
            palette.secondary.toParraColor()
        }

        let fontStyle = switch config.size {
        case .small:
            Font.TextStyle.footnote
        case .medium:
            Font.TextStyle.subheadline
        case .large:
            Font.TextStyle.headline
        }

        let (
            pressedOpacity,
            disabledOpacity,
            defaultBorderWidth,
            fontColor,
            backgroundColor
        ) = switch buttonType {
        case is OutlinedButtonComponent.Type:
            (
                0.6,
                0.6,
                1.0,
                defaults.title.fontColor ?? mainColor,
                defaults.title.background ?? defaults.background
            )
        case is ContainedButtonComponent.Type:
            (
                0.8,
                0.6,
                0.0,
                defaults.title.fontColor ?? ParraColorSwatch.neutral.shade50,
                defaults.background ?? inputAttributes?
                    .background ??
                    (
                        config.style == .primary ? palette.primary : palette
                            .secondary
                    ).toParraColor()
            )
        case is PlainButtonComponent.Type:
            (
                0.6,
                0.6,
                0.0,
                defaults.title.fontColor ?? mainColor,
                defaults.title.background ?? defaults.background
            )
        default:
            (
                0.6,
                0.6,
                0.0,
                defaults.title.fontColor ?? mainColor,
                defaults.title.background ?? defaults.background
            )
        }

        let titleAttributes = defaults.title.withUpdates(
            updates: LabelAttributes(
                // If specific values for these properties weren't provided for
                // the title label in the default state, apply the values provided
                // for the button itself.
                background: backgroundColor,
                cornerRadius: defaults.title.cornerRadius ?? defaults
                    .cornerRadius,
                // `defaults` includes a system size font that is needed as a
                // default elsewhere. User the input attributes as the override
                // point.
                font: inputAttributes?.title.font ?? Font.system(fontStyle),
                // Frame is applied here to adjust width based on config. If
                // users provide overrides for styles in different states, this
                // will need to be re-created.
                fontColor: fontColor,
                frame: defaults.title.frame ?? .init(
                    maxWidth: config.isMaxWidth ? .infinity : nil
                ),
                borderWidth: inputAttributes?.title
                    .borderWidth ?? defaultBorderWidth,
                borderColor: inputAttributes?.title.borderColor ?? mainColor
            )
        )

        // If a pressed/disabled styles are provided, use them outright.

        let titlePressedUpdates = if let titlePressed = inputAttributes?
            .titlePressed
        {
            titlePressed
        } else {
            LabelAttributes(
                background: titleAttributes.background?.opacity(pressedOpacity),
                fontColor: titleAttributes.fontColor?.opacity(pressedOpacity),
                borderColor: titleAttributes.borderColor?
                    .opacity(pressedOpacity)
            )
        }

        let titleDisabledUpdates = if let titleDisabled = inputAttributes?
            .titleDisabled
        {
            titleDisabled
        } else {
            LabelAttributes(
                background: titleAttributes.background?
                    .opacity(disabledOpacity),
                fontColor: titleAttributes.fontColor?.opacity(disabledOpacity),
                borderColor: titleAttributes.borderColor?
                    .opacity(disabledOpacity)
            )
        }

        return defaults.withUpdates(
            updates: ButtonAttributes(
                title: titleAttributes,
                titleDisabled: titleAttributes.withUpdates(
                    updates: titleDisabledUpdates
                ),
                titlePressed: titleAttributes.withUpdates(
                    updates: titlePressedUpdates
                )
            )
        )
    }
}
