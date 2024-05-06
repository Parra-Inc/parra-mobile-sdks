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
        content: TextInputContent
    ) -> some View {
        let attributes = attributeProvider.textInputAttributes(
            config: config,
            theme: theme
        )

        TextInputComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
