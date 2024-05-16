//
//  ParraGlobalComponentAttributes+Menu.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraGlobalComponentAttributes {
    func menuAttributes(
        localAttributes: ParraAttributes.Menu?,
        theme: ParraTheme
    ) -> ParraAttributes.Menu {
        let palette = theme.palette

        let titleLabel = ParraAttributes.Label.defaultInputTitle(
            for: theme
        )

        let helperLabel = ParraAttributes.Label.defaultInputHelper(
            for: theme
        )

        let unselectedMenuItemLabels = ParraAttributes.Label(
            text: ParraAttributes.Text(
                style: .body,
                weight: .regular,
                color: theme.palette.primaryText.toParraColor()
            ),
            padding: .xxl
        )

        var selectedMenuItems = unselectedMenuItemLabels
        selectedMenuItems.text = ParraAttributes.Text(
            style: .body,
            weight: .medium,
            color: theme.palette.primaryText.toParraColor()
        )

        return ParraAttributes.Menu(
            titleLabel: titleLabel,
            helperLabel: helperLabel,
            selectedMenuItemLabels: selectedMenuItems,
            unselectedMenuItemLabels: unselectedMenuItemLabels,
            tint: palette.secondaryText.toParraColor(),
            border: ParraAttributes.Border(
                width: 1,
                color: palette.secondarySeparator.toParraColor()
            ),
            cornerRadius: .md,
            padding: .md,
            background: nil
        ).mergingOverrides(localAttributes)
    }
}
