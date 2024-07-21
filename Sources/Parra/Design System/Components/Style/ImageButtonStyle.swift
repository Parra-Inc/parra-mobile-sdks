//
//  ImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {
    // MARK: - Internal

    let config: ParraImageButtonConfig
    let content: ImageButtonContent
    let attributes: ParraAttributes.ImageButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            attributes.disabled
        } else if configuration.isPressed {
            attributes.pressed
        } else {
            attributes.normal
        }

        componentFactory.buildImage(
            content: content.image,
            localAttributes: currentAttributes.image
        )
        .applyImageButtonAttributes(
            currentAttributes,
            using: themeManager.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory
}
