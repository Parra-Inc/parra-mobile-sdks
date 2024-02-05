//
//  StatefulButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ParraAttributedButtonStyle: ButtonStyle, ParraAttributedStyle {
    let config: ButtonConfig
    let content: ButtonContent
    let attributes: ButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentTitleAttributes = if content.isDisabled {
            attributes.titleDisabled
        } else if configuration.isPressed {
            attributes.titlePressed
        } else {
            attributes.title
        }

        LabelComponent(
            config: config.title,
            content: content.title,
            style: ParraAttributedLabelStyle(
                config: config.title,
                content: content.title,
                attributes: currentTitleAttributes ?? .init(),
                theme: theme
            )
        )
    }
}
