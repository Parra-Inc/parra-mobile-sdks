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
        content: LabelContent,
        localAttributes: ParraAttributes.Label? = nil
    ) -> LabelComponent {
        let attributes = attributeProvider.labelAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        LabelComponent(
            content: content,
            attributes: attributes
        )
    }

    @ViewBuilder
    func buildLabel(
        text: String,
        localAttributes: ParraAttributes.Label? = nil
    ) -> LabelComponent {
        buildLabel(
            content: LabelContent(text: text),
            localAttributes: localAttributes
        )
    }
}
