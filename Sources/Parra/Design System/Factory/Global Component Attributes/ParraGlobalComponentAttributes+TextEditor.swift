//
//  ParraGlobalComponentAttributes+TextEditor.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func textEditorAttributes(
        config: TextEditorConfig,
        localAttributes: ParraAttributes.TextEditor?,
        theme: ParraTheme
    ) -> ParraAttributes.TextEditor {
        let palette = theme.palette

        let text = ParraAttributes.Text(
            font: .body,
            color: palette.primaryText.toParraColor(),
            alignment: .leading
        )

        var placeholderText = text
        placeholderText.color = Color(UIColor.placeholderText)

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        let characterCountLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .caption,
                color: palette.secondaryText.toParraColor().opacity(0.8),
                alignment: .trailing
            ),
            padding: .custom(
                .padding(bottom: 8, trailing: 10)
            )
        )

        return ParraAttributes.TextEditor(
            text: text,
            placeholderText: placeholderText,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            characterCountLabel: characterCountLabel,
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondaryText.toParraColor()
            ),
            cornerRadius: .lg,
            padding: .md,
            background: nil,
            tint: palette.primary.toParraColor(),
            keyboardType: config.keyboardType,
            textCase: config.textCase,
            textContentType: config.textContentType,
            textInputAutocapitalization: config.textInputAutocapitalization,
            autocorrectionDisabled: config.autocorrectionDisabled,
            frame: .flexible(
                FlexibleFrameAttributes(
                    minHeight: 60,
                    idealHeight: 150,
                    maxHeight: 240
                )
            )
        ).mergingOverrides(localAttributes)
    }
}
