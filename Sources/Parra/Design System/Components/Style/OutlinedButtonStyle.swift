//
//  OutlinedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OutlinedButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.OutlinedButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            attributes.disabled
        } else if configuration.isPressed {
            attributes.pressed
        } else {
            attributes.normal
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
        .applyOutlinedButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
