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
        content: ParraAsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage?,
        theme: ParraTheme
    ) -> ParraAttributes.AsyncImage

    // MARK: Alerts

    func inlineAlertAttributes(
        content: ParraAlertContent,
        level: ParraAlertLevel,
        localAttributes: ParraAttributes.InlineAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.InlineAlert

    func toastAlertAttributes(
        content: ParraAlertContent,
        level: ParraAlertLevel,
        localAttributes: ParraAttributes.ToastAlert?,
        theme: ParraTheme
    ) -> ParraAttributes.ToastAlert

    func loadingIndicatorAlertAttributes(
        content: ParraLoadingIndicatorContent,
        localAttributes: ParraAttributes.LoadingIndicator?,
        theme: ParraTheme
    ) -> ParraAttributes.LoadingIndicator

    // MARK: Text Inputs

    func textInputAttributes(
        config: ParraTextInputConfig,
        localAttributes: ParraAttributes.TextInput?,
        theme: ParraTheme
    ) -> ParraAttributes.TextInput

    // MARK: Text Editors

    func textEditorAttributes(
        config: ParraTextEditorConfig,
        localAttributes: ParraAttributes.TextEditor?,
        theme: ParraTheme
    ) -> ParraAttributes.TextEditor

    // MARK: Buttons

    func plainButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.PlainButton?,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton

    func outlinedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.OutlinedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton

    func containedButtonAttributes(
        config: ParraTextButtonConfig,
        localAttributes: ParraAttributes.ContainedButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton

    func imageButtonAttributes(
        config: ParraImageButtonConfig,
        localAttributes: ParraAttributes.ImageButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton

    // MARK: Segmented Controls

    func segmentedControlAttributes(
        localAttributes: ParraAttributes.Segment?,
        theme: ParraTheme
    ) -> ParraAttributes.Segment

    // MARK: Menus

    func menuAttributes(
        localAttributes: ParraAttributes.Menu?,
        theme: ParraTheme
    ) -> ParraAttributes.Menu

    // MARK: Empty States

    func emptyStateAttributes(
        localAttributes: ParraAttributes.EmptyState?,
        theme: ParraTheme
    ) -> ParraAttributes.EmptyState
}
