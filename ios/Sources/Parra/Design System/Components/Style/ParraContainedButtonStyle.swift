//
//  ParraContainedButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraContainedButtonStyle: ButtonStyle {
    // MARK: - Public

    public let config: ParraTextButtonConfig
    public let content: ParraTextButtonContent
    public let attributes: ParraAttributes.ContainedButton

    @ViewBuilder
    public func makeBody(configuration: Configuration) -> some View {
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
            using: parraTheme
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
                        from: parraTheme
                    )
                    .padding(.leading, 12)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
}
