//
//  View+applyButtonAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyPlainButtonAttributes(
        _ attributes: ParraAttributes.PlainButton.StatefulAttributes,
        using theme: ParraTheme
    ) -> some View {
        applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyPadding(
            size: attributes.padding,
            from: theme
        )
    }

    @ViewBuilder
    func applyOutlinedButtonAttributes(
        _ attributes: ParraAttributes.OutlinedButton.StatefulAttributes,
        using theme: ParraTheme
    ) -> some View {
        applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyBorder(
            attributes.border,
            with: attributes.cornerRadius,
            from: theme
        )
        .applyPadding(
            size: attributes.padding,
            from: theme
        )
    }

    @ViewBuilder
    func applyContainedButtonAttributes(
        _ attributes: ParraAttributes.ContainedButton.StatefulAttributes,
        using theme: ParraTheme
    ) -> some View {
        applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyPadding(
            size: attributes.padding,
            from: theme
        )
    }

    @ViewBuilder
    func applyImageButtonAttributes(
        _ attributes: ParraAttributes.ImageButton.StatefulAttributes,
        using theme: ParraTheme
    ) -> some View {
        applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyPadding(
            size: attributes.padding,
            from: theme
        )
        .applyBorder(
            attributes.border,
            with: attributes.cornerRadius,
            from: theme
        )
    }
}
