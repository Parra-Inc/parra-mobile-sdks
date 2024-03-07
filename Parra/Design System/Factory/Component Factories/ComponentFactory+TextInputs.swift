//
//  ComponentFactory+TextInputs.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildTextInput(
        config: TextInputConfig,
        content: TextInputContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            TextField<Text>,
            TextInputConfig,
            TextInputContent,
            TextInputAttributes
        >? = nil,
        localAttributes: TextInputAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.textInputAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = TextInputComponent
            .applyStandardCustomizations(
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
            let style = ParraAttributedTextInputStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            TextInputComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }
}
