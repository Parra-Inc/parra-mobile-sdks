//
//  ComponentFactory+TextEditors.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildTextEditor(
        config: TextEditorConfig,
        content: TextEditorContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            TextEditor,
            TextEditorConfig,
            TextEditorContent,
            TextEditorAttributes
        >? = nil,
        localAttributes: TextEditorAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.textEditorAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = TextEditorComponent
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
    }
}
