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
        config: ParraTextEditorConfig,
        content: ParraTextEditorContent,
        localAttributes: ParraAttributes.TextEditor? = nil
    ) -> some View {
        let attributes = attributeProvider.textEditorAttributes(
            config: config,
            localAttributes: localAttributes,
            theme: theme
        )

        TextEditorComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
