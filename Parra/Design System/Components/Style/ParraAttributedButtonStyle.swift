//
//  ParraAttributedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedButtonStyle: ButtonStyle, ParraAttributedStyle {
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
            content: content.title,
            style: ParraAttributedLabelStyle(
                content: content.title,
                attributes: currentTitleAttributes ?? .init(),
                theme: theme
            )
        )
    }
}
