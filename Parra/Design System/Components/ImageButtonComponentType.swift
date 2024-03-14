//
//  ImageButtonComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ImageButtonComponentType: View {
    var config: ImageButtonConfig { get }
    var content: ImageButtonContent { get }
    var style: ParraAttributedImageButtonStyle { get }

    init(
        config: ImageButtonConfig,
        content: ImageButtonContent,
        style: ParraAttributedImageButtonStyle,
        onPress: @escaping () -> Void
    )
}

extension ImageButtonComponentType {
    static func applyStandardCustomizations(
        onto inputAttributes: ImageButtonAttributes?,
        theme: ParraTheme,
        config: ImageButtonConfig
    ) -> ImageButtonAttributes {
        let defaults = ImageButtonAttributes.defaultAttributes(
            for: theme,
            with: config
        ).withUpdates(updates: inputAttributes)

        let (
            pressedOpacity,
            disabledOpacity
        ) = switch config.variant {
        case .outlined:
            (
                0.6,
                0.6
            )
        case .contained:
            (
                0.8,
                0.6
            )
        case .plain:
            (
                0.6,
                0.6
            )
        }

        let imageAttributes = defaults.image

        // If a pressed/disabled styles are provided, use them outright.

        let imagePressedUpdates = if let imagePressed = inputAttributes?
            .imagePressed
        {
            imagePressed
        } else {
            ImageAttributes(
                background: imageAttributes.background?.opacity(pressedOpacity),
                opacity: pressedOpacity,
                borderColor: imageAttributes.borderColor?
                    .opacity(pressedOpacity)
            )
        }

        let imageDisabledUpdates = if let imageDisabled = inputAttributes?
            .imageDisabled
        {
            imageDisabled
        } else {
            ImageAttributes(
                background: imageAttributes.background?
                    .opacity(disabledOpacity),
                opacity: disabledOpacity,
                borderColor: imageAttributes.borderColor?
                    .opacity(disabledOpacity)
            )
        }

        return defaults.withUpdates(
            updates: ImageButtonAttributes(
                image: imageAttributes,
                imageDisabled: imageAttributes.withUpdates(
                    updates: imageDisabledUpdates
                ),
                imagePressed: imageAttributes.withUpdates(
                    updates: imagePressedUpdates
                )
            )
        )
    }
}
