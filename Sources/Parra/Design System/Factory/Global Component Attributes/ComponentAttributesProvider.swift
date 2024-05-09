//
//  ComponentAttributesProvider.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public protocol ComponentAttributesProvider {
    // MARK: Labels

    func labelAttributes(
        for textStyle: ParraTextStyle,
        theme: ParraTheme
    ) -> ParraAttributes.Label

    // MARK: Badges

    func badgeAttributes(
        for size: ParraBadgeSize,
        variant: ParraBadgeVariant,
        swatch: ParraColorSwatch?,
        theme: ParraTheme
    ) -> ParraAttributes.Badge

    func imageAttributes(
        content: ParraImageContent
    ) -> ParraAttributes.Image

    func asyncImageAttributes(
        content: AsyncImageContent
    ) -> ParraAttributes.AsyncImage

    // MARK: Alerts

    func inlineAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        theme: ParraTheme
    ) -> ParraAttributes.InlineAlert

    func toastAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        theme: ParraTheme
    ) -> ParraAttributes.ToastAlert

    // MARK: Text Inputs

    func textInputAttributes(
        config: TextInputConfig,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput

    // MARK: Buttons

    func plainButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton

    func outlinedButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton

    func containedButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton

    func imageButtonAttributes(
        variant: ParraButtonVariant,
        for size: ParraImageButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton
}
