//
//  ComponentFactory+TextInputs.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    @ViewBuilder
    func buildTextInput(
        config: ParraTextInputConfig,
        content: ParraTextInputContent,
        localAttributes: ParraAttributes.TextInput? = nil
    ) -> ParraTextInputComponent {
        let attributes = attributeProvider.textInputAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraTextInputComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
