//
//  ComponentFactory+Labels.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildLabel(
        config: LabelConfig,
        content: LabelContent,
        suppliedBuilder: LocalComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        localAttributes: LabelAttributes? = nil
    ) -> some View {
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

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedBuilder,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedLabelStyle(
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            LabelComponent(
                content: content,
                style: style
            )
        }
    }
}
