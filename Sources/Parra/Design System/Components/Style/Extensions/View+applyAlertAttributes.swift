//
//  View+applyAlertAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyInlineAlertAttributes(
        _ attributes: ParraAttributes.InlineAlert,
        using theme: ParraTheme
    ) -> some View {
        applyPadding(
            size: attributes.padding,
            from: theme
        )
        .background(attributes.background ?? .clear)
        .applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyBorder(
            attributes.border,
            with: attributes.cornerRadius,
            from: theme
        )
    }

    @ViewBuilder
    func applyToastAlertAttributes(
        _ attributes: ParraAttributes.ToastAlert,
        using theme: ParraTheme
    ) -> some View {
        applyPadding(
            size: attributes.padding,
            from: theme
        )
        .background(attributes.background ?? .clear)
        .applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
    }
}
