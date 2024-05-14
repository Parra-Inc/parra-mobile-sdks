//
//  View+applyTextEditorAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyTextEditorAttributes(
        _ attributes: ParraAttributes.TextEditor,
        using theme: ParraTheme
    ) -> some View {
        tint(attributes.tint)
            .background(.clear)
            .contentMargins(
                .all,
                EdgeInsets(
                    vertical: 4,
                    horizontal: 8
                ),
                for: .automatic
            )
            .applyFrame(attributes.frame)
            .background(attributes.background)
            .applyCornerRadii(
                size: attributes.cornerRadius,
                from: theme
            )
            .applyBorder(
                attributes.border,
                with: attributes.cornerRadius,
                from: theme
            )
            .applyTextAttributes(attributes.text, using: theme)
            .keyboardType(attributes.keyboardType ?? .default)
            .textCase(attributes.textCase)
            .textContentType(attributes.textContentType)
            .textInputAutocapitalization(attributes.textInputAutocapitalization)
            .autocorrectionDisabled(attributes.autocorrectionDisabled ?? false)
    }
}
