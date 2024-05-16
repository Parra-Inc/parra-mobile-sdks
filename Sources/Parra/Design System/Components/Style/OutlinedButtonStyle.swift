//
//  OutlinedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct OutlinedButtonStyle: ButtonStyle {
    // MARK: - Internal

    let config: ParraTextButtonConfig
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

        componentFactory.buildLabel(
            content: content.text,
            localAttributes: currentAttributes.label
        )
        .applyOutlinedButtonAttributes(
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
    @EnvironmentObject private var componentFactory: ComponentFactory
}
