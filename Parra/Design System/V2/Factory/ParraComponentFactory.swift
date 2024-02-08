//
//  LocalComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ComponentBuilder {
    // I don't know why, but these generic typealiases have to be nested within a type.
    // If they're top level, any callsite reports not finding them on the Parra module.
    typealias Factory<
        V: View,
        Config,
        Content,
        Attributes
    > = (
        _ config: Config,
        _ content: Content?,
        _ defaultAttributes: ParraStyleAttributes
    ) -> V?
}

protocol ParraComponentFactory {}

class ComponentFactory<Factory: ParraComponentFactory>: ObservableObject {
    private let local: Factory?
    private let global: GlobalComponentAttributes?
    private let theme: ParraTheme

    init(
        local: Factory?,
        global: GlobalComponentAttributes?,
        theme: ParraTheme
    ) {
        self.local = local
        self.global = global
        self.theme = theme
    }

    @ViewBuilder
    func buildLabel(
        component componentKeyPath: KeyPath<Factory, ComponentBuilder.Factory<some View, LabelConfig, LabelContent, LabelAttributes>?>,
        config: LabelConfig,
        content: LabelContent?,
        localAttributes: LabelAttributes? = nil
    ) -> some View {
        if let content {
            let attributes = if let factory = global?.labelAttributeFactory {
                factory(config, content, localAttributes)
            } else {
                localAttributes
            }

            let mergedAttributes = LabelComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

            // If a container level factory function was provided for this component,
            // use it and supply global attribute overrides instead of local, if provided.
            if let builder = local?[keyPath: componentKeyPath],
               let view = builder(config, content, mergedAttributes) {

                view
            } else {
                let style = ParraAttributedLabelStyle(
                    config: config,
                    content: content,
                    attributes: mergedAttributes,
                    theme: theme
                )

                LabelComponent(
                    config: config,
                    content: content,
                    style: style
                )
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func buildButton(
        variant: ButtonVariant,
        component componentKeyPath: KeyPath<Factory, ComponentBuilder.Factory<some View, ButtonConfig, ButtonContent, ButtonAttributes>?>,
        config: ButtonConfig,
        content: ButtonContent?,
        localAttributes: ButtonAttributes
    ) -> some View {
        if let content {
            let attributes = if let factory = global?.buttonAttributeFactory {
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
                    config: config
                )
            case .outlined:
                OutlinedButtonComponent.applyStandardCustomizations(
                    onto: attributes,
                    theme: theme,
                    config: config
                )
            case .contained:
                ContainedButtonComponent.applyStandardCustomizations(
                    onto: attributes,
                    theme: theme,
                    config: config
                )
            }

            // If a container level factory function was provided for this component,
            // use it and supply global attribute overrides instead of local, if provided.
            if let builder = local?[keyPath: componentKeyPath],
               let view = builder(config, content, mergedAttributes) {

                view
            } else {
                let style = ParraAttributedButtonStyle(
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
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func buildMenu(
        component componentKeyPath: KeyPath<Factory, ComponentBuilder.Factory<some View, MenuConfig, MenuContent, MenuAttributes>?>,
        config: MenuConfig,
        content: MenuContent?,
        localAttributes: MenuAttributes? = nil
    ) -> some View {
        if let content {
            let attributes = if let factory = global?.menuAttributeFactory {
                factory(config, content, localAttributes)
            } else {
                localAttributes
            }

            let mergedAttributes = MenuComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

            // If a container level factory function was provided for this component,
            // use it and supply global attribute overrides instead of local, if provided.
            if let builder = local?[keyPath: componentKeyPath],
               let view = builder(config, content, mergedAttributes) {

                view
            } else {
                let style = ParraAttributedMenuStyle(
                    config: config,
                    content: content,
                    attributes: mergedAttributes,
                    theme: theme
                )

                MenuComponent(
                    config: config,
                    content: content,
                    style: style
                )
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func buildTextEditor(
        component componentKeyPath: KeyPath<Factory, ComponentBuilder.Factory<some View, TextEditorConfig, TextEditorContent, TextEditorAttributes>?>,
        config: TextEditorConfig,
        content: TextEditorContent?,
        localAttributes: TextEditorAttributes? = nil
    ) -> some View {
        if let content {
            let attributes = if let factory = global?.textEditorAttributeFactory {
                factory(config, content, localAttributes)
            } else {
                localAttributes
            }

            let mergedAttributes = TextEditorComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

            // If a container level factory function was provided for this component,
            // use it and supply global attribute overrides instead of local, if provided.
            if let builder = local?[keyPath: componentKeyPath],
               let view = builder(config, content, mergedAttributes) {

                view
            } else {
                let style = ParraAttributedTextEditorStyle(
                    config: config,
                    content: content,
                    attributes: mergedAttributes,
                    theme: theme
                )

                TextEditorComponent(
                    config: config,
                    content: content,
                    style: style
                )
            }
        } else {
            EmptyView()
        }
    }
}
