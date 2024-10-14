//
//  ComponentFactory+Labels.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    func buildLabel(
        content: ParraLabelContent,
        localAttributes: ParraAttributes.Label? = nil
    ) -> ParraLabelComponent {
        let attributes = attributeProvider.labelAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraLabelComponent(
            content: content,
            attributes: attributes
        )
    }

    func buildLabel(
        text: String,
        localAttributes: ParraAttributes.Label? = nil
    ) -> ParraLabelComponent {
        return buildLabel(
            content: ParraLabelContent(text: text),
            localAttributes: localAttributes
        )
    }
}
