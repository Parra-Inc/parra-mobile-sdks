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
    let content: ParraTextButtonContent
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

        componentFactory.buildLabel(
            content: content.text,
            localAttributes: currentAttributes.label
        )
        .applyContainedButtonAttributes(
            currentAttributes,
            using: themeManager.theme
        )
        .overlay(
            alignment: .leading
        ) {
            if content.isLoading {
                ProgressView()
                    .tint(currentAttributes.label.text.color ?? .black)
                    // Apply theme padding to get within the button's bounds +
                    // extra for an inner pad.
                    .applyPadding(
                        size: currentAttributes.padding,
                        on: .leading,
                        from: themeManager.theme
                    )
                    .padding(.leading, 12)
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory
}
