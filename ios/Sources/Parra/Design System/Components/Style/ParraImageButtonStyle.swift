//
//  ParraImageButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraImageButtonStyle: ButtonStyle {
    // MARK: - Public

    public let config: ParraImageButtonConfig
    public let content: ParraImageButtonContent
    public let attributes: ParraAttributes.ImageButton

    @ViewBuilder
    public func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            attributes.disabled
        } else if configuration.isPressed {
            attributes.pressed
        } else {
            attributes.normal
        }

        innerContent(with: currentAttributes).applyImageButtonAttributes(
            currentAttributes,
            using: parraTheme
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder
    private func innerContent(
        with attributes: ParraAttributes.ImageButton.StatefulAttributes
    ) -> some View {
        if content.isLoading {
            ProgressView()
        } else {
            componentFactory.buildImage(
                content: content.image,
                localAttributes: attributes.image
            )
        }
    }
}
