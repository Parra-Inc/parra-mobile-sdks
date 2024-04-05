//
//  ComponentFactory+Menus.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildMenu(
        config: MenuConfig,
        content: MenuContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            Menu<Text, Button<Text>>,
            MenuConfig,
            MenuContent,
            MenuAttributes
        >? = nil,
        localAttributes: MenuAttributes? = nil
    ) -> some View {
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

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
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
    }
}
