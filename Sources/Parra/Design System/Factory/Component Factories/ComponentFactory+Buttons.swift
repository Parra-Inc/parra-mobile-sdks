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
        onPress: @escaping () -> Void
    ) -> some View {
        let (
            attributes,
            pressedAttributes,
            disabledAttributes
        ) = createButtonAttributeStateVariants(
            for: config.size,
            type: config.style,
            factory: attributeProvider.plainButtonAttributes
        )

        let style = PlainButtonStyle(
            config: config,
            content: content,
            attributes: attributes,
            pressedAttributes: pressedAttributes,
            disabledAttributes: disabledAttributes
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
        onPress: @escaping () -> Void
    ) -> some View {
        let (
            attributes,
            pressedAttributes,
            disabledAttributes
        ) = createButtonAttributeStateVariants(
            for: config.size,
            type: config.style,
            factory: attributeProvider.outlinedButtonAttributes
        )

        let style = OutlinedButtonStyle(
            config: config,
            content: content,
            attributes: attributes,
            pressedAttributes: pressedAttributes,
            disabledAttributes: disabledAttributes
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
        onPress: @escaping () -> Void
    ) -> some View {
        let (
            attributes,
            pressedAttributes,
            disabledAttributes
        ) = createButtonAttributeStateVariants(
            for: config.size,
            type: config.style,
            factory: attributeProvider.containedButtonAttributes
        )

        let style = ContainedButtonStyle(
            config: config,
            content: content,
            attributes: attributes,
            pressedAttributes: pressedAttributes,
            disabledAttributes: disabledAttributes
        )

        ContainedButtonComponent(
            config: config,
            content: content,
            style: style,
            onPress: onPress
        )
    }

    private func createButtonAttributeStateVariants<T>(
        for size: ParraButtonSize,
        type: ParraButtonType,
        factory: (
            _ state: ParraButtonState,
            _ size: ParraButtonSize,
            _ type: ParraButtonType,
            _ theme: ParraTheme
        ) -> T
    ) -> (
        normal: T,
        pressed: T,
        disabled: T
    ) {
        return (
            factory(.normal, size, type, theme),
            factory(.pressed, size, type, theme),
            factory(.disabled, size, type, theme)
        )
    }

    @ViewBuilder
    func buildImageButton(
        variant: ParraButtonVariant,
        config: ImageButtonConfig,
        content: ImageButtonContent,
        localAttributes: ImageButtonAttributes? = nil,
        onPress: @escaping () -> Void
    ) -> some View {
        EmptyView()
//        let mergedAttributes = ImageButtonComponent
//            .applyStandardCustomizations(
//                onto: localAttributes,
//                theme: theme,
//                config: config
//            )
//
//        // If a container level factory function was provided for this
//        // component, use it and supply global attribute overrides instead
//        // of local, if provided.
//        if let builder = suppliedBuilder,
//           let view = builder(config, content, mergedAttributes, onPress)
//        {
//            view
//        } else {
//            let style = ParraAttributedImageButtonStyle(
//                config: config,
//                content: content,
//                attributes: mergedAttributes,
//                theme: theme
//            )
//
//            ImageButtonComponent(
//                config: config,
//                content: content,
//                style: style,
//                onPress: onPress
//            )
//        }
    }
}
