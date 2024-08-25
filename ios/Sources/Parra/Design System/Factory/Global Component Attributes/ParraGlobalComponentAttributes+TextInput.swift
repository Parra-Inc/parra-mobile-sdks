//
//  ParraGlobalComponentAttributes+TextInput.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func textInputAttributes(
        config: ParraTextInputConfig,
        localAttributes: ParraAttributes.TextInput? = nil,
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

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        var errorLabel = helperLabel
        errorLabel.text.color = palette.error.toParraColor()

        return ParraAttributes.TextInput(
            text: text,
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            errorLabel: errorLabel,
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondarySeparator.toParraColor()
            ),
            cornerRadius: .lg,
            padding: .md,
            background: palette.secondaryBackground,
            tint: palette.primary.toParraColor(),
            keyboardType: config.keyboardType,
            textCase: config.textCase,
            textContentType: config.textContentType,
            textInputAutocapitalization: config.textInputAutocapitalization,
            autocorrectionDisabled: config.autocorrectionDisabled,
            frame: .fixed(FixedFrameAttributes(height: 52))
        ).mergingOverrides(localAttributes)
    }
}

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
