//
//  ImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: ImageButtonConfig
    let content: ImageButtonContent

    let attributes: ParraAttributes.ImageButton
    let pressedAttributes: ParraAttributes.ImageButton
    let disabledAttributes: ParraAttributes.ImageButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            disabledAttributes
        } else if configuration.isPressed {
            pressedAttributes
        } else {
            attributes
        }

        ImageComponent(
            content: content.image,
            attributes: currentAttributes.image
        )
        .applyImageButtonAttributes(
            attributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
