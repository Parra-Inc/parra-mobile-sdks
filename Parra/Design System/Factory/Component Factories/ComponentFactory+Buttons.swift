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
    func buildTextButton(
        variant: ButtonVariant,
        config: TextButtonConfig,
        content: TextButtonContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        localAttributes: TextButtonAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.textButtonAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        // Dynamically get default attributes for different button types.
        let mergedAttributes = switch variant {
        case .plain:
            PlainButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: PlainButtonComponent.self
            )
        case .outlined:
            OutlinedButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: OutlinedButtonComponent.self
            )
        case .contained:
            ContainedButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: ContainedButtonComponent.self
            )
        }

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedTextButtonStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            switch variant {
            case .plain:
                PlainButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            case .outlined:
                OutlinedButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            case .contained:
                ContainedButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            }
        }
    }

    @ViewBuilder
    func buildImageButton(
        variant: ButtonVariant,
        config: ImageButtonConfig,
        content: ImageButtonContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        localAttributes: ImageButtonAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.imageButtonAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = ImageButtonComponent
            .applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedImageButtonStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            ImageButtonComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }
}
