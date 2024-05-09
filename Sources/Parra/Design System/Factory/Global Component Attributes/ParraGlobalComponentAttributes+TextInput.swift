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
        config: TextInputConfig,
        localAttributes: ParraAttributes.TextInput? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput {
        let palette = theme.palette

        let text = ParraAttributes.Text(
            font: .body,
            color: palette.primaryText.toParraColor()
        )

        let titleLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .callout,
                color: palette.primaryText.toParraColor()
            ),
            padding: .custom(
                EdgeInsets(top: 0, leading: 1, bottom: 8, trailing: 2)
            )
        )

        let helperLabel = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .caption2,
                color: palette.secondaryText.toParraColor()
            ),
            padding: .custom(
                EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 2)
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
            background: nil,
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
