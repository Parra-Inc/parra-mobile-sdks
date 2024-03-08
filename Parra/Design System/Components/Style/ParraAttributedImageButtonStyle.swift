//
//  ParraAttributedImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedImageButtonStyle: ButtonStyle, ParraAttributedStyle {
    let config: ImageButtonConfig
    let content: ImageButtonContent
    let attributes: ImageButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let primaryColor = theme.palette.primary.toParraColor()

        let defaults = ImageAttributes(
            tint: primaryColor,
            borderColor: primaryColor
        ).withUpdates(
            updates: attributes.image
        )

        let currentAttributes = if content.isDisabled {
            attributes.imageDisabled ?? defaults
        } else if configuration.isPressed {
            attributes.imagePressed ?? defaults
        } else {
            defaults
        }

        ImageComponent(
            content: content.image,
            attributes: currentAttributes
        )
    }
}
