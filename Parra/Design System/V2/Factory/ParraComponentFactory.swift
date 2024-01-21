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
        Config: ComponentConfig,
        Content: ComponentContent,
        Style: ComponentStyle
    > = (
        _ config: Config,
        _ content: Content?,
        _ defaultStyle: Style
    ) -> V?
}

protocol ParraComponentFactory {}

class ComponentFactory<Factory: ParraComponentFactory>: ObservableObject {
    private let local: Factory
    private let global: GlobalComponentStylizer
    private let theme: ParraTheme

    init(
        local: Factory,
        global: GlobalComponentStylizer,
        theme: ParraTheme
    ) {
        self.local = local
        self.global = global
        self.theme = theme
    }

    @ViewBuilder
    /// A function indended for use anywhere that we want to create a base component within a Parra container.
    /// This builder takes styles provided by the ``GlobalComponentStylizer`` into consideration, as well
    /// as override implementations of the component type provided by a local component factory provided by the
    /// end user. If either of these aren't provided, we fall back on both default styles and/or default components
    /// respectively.
    func build<
        Config, Content, Style, DefaultComponent
    >(
        component componentKeyPath: KeyPath<Factory, ComponentBuilder.Factory<some View, Config, Content, Style>?>,
        config: Config,
        content: Content?,
        localStyle: Style,
        defaultComponentType: DefaultComponent.Type
    ) -> some View where Config : ComponentConfig, Content : ComponentContent, Style : ComponentStyle, DefaultComponent: Component, DefaultComponent.Config == Config, DefaultComponent.Content == Content, DefaultComponent.Style == Style
    {
        if let content {
            // local style should be applied on top of default style for the element type
            // before it is used by the default component or passed to any user facing factories.
            let mergedStyles = defaultComponentType.defaultStyleInContext(
                of: theme,
                with: config
            ).withUpdates(updates: localStyle)

            let stylizer: GlobalComponentStylizer.ComponentStylizer<Config, Content, Style>? = global.getStylizer(
                styleType: Style.self
            )

            let style = if let stylizer {
                stylizer(config, content, mergedStyles)
            } else {
                mergedStyles
            }

            if let builder = local[keyPath: componentKeyPath], let view = builder(config, content, style) {
                view
            } else {
                defaultComponentType.init(
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
