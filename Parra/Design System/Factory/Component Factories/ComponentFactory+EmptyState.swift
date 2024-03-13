//
//  ComponentFactory+EmptyState.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildEmptyState(
        config: EmptyStateConfig,
        content: EmptyStateContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            AnyView,
            EmptyStateConfig,
            EmptyStateContent,
            EmptyStateAttributes
        >? = nil,
        localAttributes: EmptyStateAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.emptyStateAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = EmptyStateComponent.applyStandardCustomizations(
            onto: attributes,
            theme: theme,
            config: config
        )

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead of
        // local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedEmptyStateStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            EmptyStateComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }
}
