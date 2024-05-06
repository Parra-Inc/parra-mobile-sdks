//
//  ParraAttributedImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedImageButtonStyle: ButtonStyle, ParraAttributedStyle {
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
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
