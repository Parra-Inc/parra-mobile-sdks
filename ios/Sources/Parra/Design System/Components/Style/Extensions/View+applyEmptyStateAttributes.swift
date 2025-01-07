//
//  View+applyEmptyStateAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyEmptyStateAttributes(
        _ attributes: ParraAttributes.EmptyState,
        using theme: ParraTheme
    ) -> some View {
        applyPadding(
            size: attributes.padding,
            from: theme
        )
        .background(attributes.background ?? theme.palette.primaryBackground)
        .tint(attributes.tint ?? theme.palette.primary.toParraColor())
    }
}
