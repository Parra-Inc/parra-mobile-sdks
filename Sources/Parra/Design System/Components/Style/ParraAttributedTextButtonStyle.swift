//
//  ParraAttributedTextButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedTextButtonStyle: ButtonStyle, ParraAttributedStyle {
    let config: TextButtonConfig
    let content: TextButtonContent
    let attributes: TextButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentTitleAttributes = if content.isDisabled {
            attributes.titleDisabled ?? attributes.title
        } else if configuration.isPressed {
            attributes.titlePressed ?? attributes.title
        } else {
            attributes.title
        }

        LabelComponent(
            content: content.text,
            style: ParraAttributedLabelStyle(
                content: content.text,
                attributes: currentTitleAttributes,
                theme: theme,
                isLoading: content.isLoading
            )
        )
    }
}
