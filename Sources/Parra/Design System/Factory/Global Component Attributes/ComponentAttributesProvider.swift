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
        localAttributes: ParraAttributes.Label?,
        theme: ParraTheme
    ) -> ParraAttributes.Label

    // MARK: Badges

    func badgeAttributes(
        for size: ParraBadgeSize,
        variant: ParraBadgeVariant,
        swatch: ParraColorSwatch?,
        localAttributes: ParraAttributes.Badge?,
        theme: ParraTheme
    ) -> ParraAttributes.Badge

    func imageAttributes(
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image?,
        theme: ParraTheme
    ) -> ParraAttributes.Image

    func asyncImageAttributes(
        content: AsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage?,
        theme: ParraTheme
    ) -> ParraAttributes.AsyncImage

    // MARK: Alerts

    func inlineAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        localAttributes: ParraAttributes.InlineAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.InlineAlert

    func toastAlertAttributes(
        content: ParraAlertContent,
        level: AlertLevel,
        localAttributes: ParraAttributes.ToastAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.ToastAlert

    // MARK: Text Inputs

    func textInputAttributes(
        config: TextInputConfig,
        localAttributes: ParraAttributes.TextInput?,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput

    // MARK: Text Editors

    func textEditorAttributes(
        config: TextEditorConfig,
        localAttributes: ParraAttributes.TextEditor?,
        theme: ParraTheme
    ) -> ParraAttributes.TextEditor

    // MARK: Buttons

    func plainButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        localAttributes: ParraAttributes.PlainButton?,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton

    func outlinedButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        localAttributes: ParraAttributes.OutlinedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton

    func containedButtonAttributes(
        for size: ParraButtonSize,
        with type: ParraButtonType,
        localAttributes: ParraAttributes.ContainedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton

    func imageButtonAttributes(
        variant: ParraButtonVariant,
        for size: ParraImageButtonSize,
        with type: ParraButtonType,
        localAttributes: ParraAttributes.ImageButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton

    // MARK: Segmented Controls

    func segmentedControlAttributes(
        localAttributes: ParraAttributes.Segment?,
        theme: ParraTheme
    ) -> ParraAttributes.Segment
}
