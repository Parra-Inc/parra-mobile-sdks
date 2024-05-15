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
        config: ParraTextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.PlainButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.plainButtonAttributes(
            config: config,
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
        config: ParraTextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.OutlinedButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.outlinedButtonAttributes(
            config: config,
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
        config: ParraTextButtonConfig,
        content: TextButtonContent,
        localAttributes: ParraAttributes.ContainedButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.containedButtonAttributes(
            config: config,
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
        config: ParraImageButtonConfig,
        content: ImageButtonContent,
        localAttributes: ParraAttributes.ImageButton? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        let attributes = attributeProvider.imageButtonAttributes(
            config: config,
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
