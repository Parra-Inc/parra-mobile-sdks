//
//  ComponentFactory+Buttons.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildPlainButton(
        config: TextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.PlainButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.plainButtonAttributes(
            for: config.size,
            with: config.type,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = PlainButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        PlainButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    @ViewBuilder
    func buildOutlinedButton(
        config: TextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.OutlinedButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.outlinedButtonAttributes(
            for: config.size,
            with: config.type,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = OutlinedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        OutlinedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    @ViewBuilder
    func buildContainedButton(
        config: TextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.ContainedButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.containedButtonAttributes(
            for: config.size,
            with: config.type,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ContainedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        ContainedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    @ViewBuilder
    func buildImageButton(
        config: ImageButtonConfig,
        content: ImageButtonContent,
        localAttributes: ParraAttributes.ImageButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.imageButtonAttributes(
            variant: config.variant,
            for: config.size,
            with: config.type,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ImageButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        ImageButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }
}
