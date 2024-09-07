//
//  ParraAttributes.TextInput+fakeAttributes.swift
//
//
//  Created by Mick MacCallum on 9/6/24.
//

import SwiftUI

extension ParraAttributes.TextInput {
    static func fakeLabelAttributes(
        config: ParraTextInputConfig,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput {
        let palette = theme.palette

        let text = ParraAttributes.Text(
            style: .body,
            color: palette.primaryText.toParraColor()
        )

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label(
            padding: .zero,
            frame: .fixed(
                FixedFrameAttributes(width: 0, height: 0)
            )
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        return ParraAttributes.TextInput(
            text: text,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            border: ParraAttributes.Border(
                width: 0
            ),
            cornerRadius: .zero,
            padding: .zero,
            background: nil,
            tint: palette.primary.toParraColor(),
            keyboardType: config.keyboardType,
            textCase: config.textCase,
            textContentType: config.textContentType,
            textInputAutocapitalization: config.textInputAutocapitalization,
            autocorrectionDisabled: config.autocorrectionDisabled,
            frame: .fixed(FixedFrameAttributes(height: 40))
        )
    }
}
