//
//  PlainButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PlainButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.PlainButton
    let pressedAttributes: ParraAttributes.PlainButton
    let disabledAttributes: ParraAttributes.PlainButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            disabledAttributes
        } else if configuration.isPressed {
            pressedAttributes
        } else {
            attributes
        }

        var labelAttributes = currentAttributes.label
        let _ = labelAttributes.frame = .flexible(
            FlexibleFrameAttributes(
                maxWidth: config.isMaxWidth ? .infinity : nil
            )
        )

        LabelComponent(
            content: content.text,
            attributes: labelAttributes
        )
        .applyPlainButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
