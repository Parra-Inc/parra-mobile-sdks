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

        let titleLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .body,
                weight: .medium,
                color: palette.primaryText.toParraColor(),
                alignment: .leading
            ),
            padding: .custom(
                .padding(bottom: 10, trailing: 2)
            )
        )

        let helperLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .caption,
                color: palette.secondaryText.toParraColor(),
                alignment: .trailing
            ),
            padding: .custom(
                .padding(top: 3, bottom: 4, trailing: 2)
            ),
            frame: .flexible(
                FlexibleFrameAttributes(
                    maxWidth: .infinity,
                    minHeight: 12,
                    idealHeight: 12,
                    maxHeight: 12,
                    alignment: .trailing
                )
            )
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

        let border = ParraAttributes.Border(
            width: 1,
            color: palette.secondaryText.toParraColor()
        )

        return ParraAttributes.TextEditor(
            text: text,
            placeholderText: placeholderText,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            characterCountLabel: characterCountLabel,
            border: border,
            cornerRadius: .md,
            padding: .md,
            background: nil,
            tint: palette.primary.toParraColor(),
            frame: .flexible(
                FlexibleFrameAttributes(
                    minHeight: 60,
                    idealHeight: 150,
                    maxHeight: 240
                )
            )
        )
    }
}
