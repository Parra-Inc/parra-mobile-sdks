//
//  ComponentFactory+Buttons.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    func buildPlainButton(
        config: ParraTextButtonConfig,
        content: ParraTextButtonContent,
        localAttributes: ParraAttributes.PlainButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraPlainButtonComponent {
        let attributes = attributeProvider.plainButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ParraPlainButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraPlainButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildPlainButton(
        config: ParraTextButtonConfig,
        text: String,
        localAttributes: ParraAttributes.PlainButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraPlainButtonComponent {
        let attributes = attributeProvider.plainButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let content = ParraTextButtonContent(text: text)

        let style = ParraPlainButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraPlainButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildOutlinedButton(
        config: ParraTextButtonConfig,
        content: ParraTextButtonContent,
        localAttributes: ParraAttributes.OutlinedButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraOutlinedButtonComponent {
        let attributes = attributeProvider.outlinedButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ParraOutlinedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraOutlinedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildOutlinedButton(
        config: ParraTextButtonConfig,
        text: String,
        localAttributes: ParraAttributes.OutlinedButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraOutlinedButtonComponent {
        let attributes = attributeProvider.outlinedButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let content = ParraTextButtonContent(text: text)

        let style = ParraOutlinedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraOutlinedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildContainedButton(
        config: ParraTextButtonConfig,
        content: ParraTextButtonContent,
        localAttributes: ParraAttributes.ContainedButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraContainedButtonComponent {
        let attributes = attributeProvider.containedButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ParraContainedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraContainedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildContainedButton(
        config: ParraTextButtonConfig,
        text: String,
        localAttributes: ParraAttributes.ContainedButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraContainedButtonComponent {
        let attributes = attributeProvider.containedButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let content = ParraTextButtonContent(text: text)

        let style = ParraContainedButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraContainedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    func buildImageButton(
        config: ParraImageButtonConfig,
        content: ParraImageButtonContent,
        localAttributes: ParraAttributes.ImageButton? = nil,
        onPress: @escaping () -> Void
    ) -> ParraImageButtonComponent {
        let attributes = attributeProvider.imageButtonAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        let style = ParraImageButtonStyle(
            config: config,
            content: content,
            attributes: attributes
        )

        return ParraImageButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }
}
