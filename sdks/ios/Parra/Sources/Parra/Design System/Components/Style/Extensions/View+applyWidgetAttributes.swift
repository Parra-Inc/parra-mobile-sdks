//
//  View+applyWidgetAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyDefaultWidgetAttributes(
        using theme: ParraTheme
    ) -> some View {
        let attributes = ParraAttributes.Widget.default(
            with: theme
        )

        applyWidgetAttributes(
            attributes: attributes,
            using: theme
        )
    }

    @ViewBuilder
    func applyWidgetAttributes(
        attributes: ParraAttributes.Widget,
        using theme: ParraTheme
    ) -> some View {
        applyPadding(
            size: attributes.contentPadding,
            from: theme
        )
        .background(attributes.background ?? .clear)
        .applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        .applyPadding(
            size: attributes.padding,
            from: theme
        )
    }
}
