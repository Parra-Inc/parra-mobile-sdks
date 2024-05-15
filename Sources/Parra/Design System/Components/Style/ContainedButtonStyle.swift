//
//  ContainedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ContainedButtonStyle: ButtonStyle {
    // MARK: - Internal

    let config: ParraTextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.ContainedButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            attributes.disabled
        } else if configuration.isPressed {
            attributes.pressed
        } else {
            attributes.normal
        }

        LabelComponent(
            content: content.text,
            attributes: currentAttributes.label
        )
        .applyContainedButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
        .overlay(
            alignment: .leading
        ) {
            if content.isLoading {
                ProgressView()
                    .tint(currentAttributes.label.text.color ?? .black)
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}
