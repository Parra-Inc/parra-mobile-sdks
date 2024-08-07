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
        config: ParraTextInputConfig,
        content: ParraTextInputContent,
        localAttributes: ParraAttributes.TextInput? = nil
    ) -> some View {
        let attributes = attributeProvider.textInputAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        TextInputComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
