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
    func applyDefaultWidgetAttributesWithoutPadding(
        using theme: ParraTheme
    ) -> some View {
        let attributes = ParraAttributes.Widget.default(
            with: theme
        )

        applyWidgetAttributes(
            attributes: attributes.withoutContentPadding(),
            using: theme
        )
    }

    @ViewBuilder
    func applyWidgetAttributes(
        attributes: ParraAttributes.Widget,
        using theme: ParraTheme
    ) -> some View {
        applyCornerRadii(
            size: attributes.cornerRadius,
            from: theme
        )
        // background won't continue in safe area unless after corner radius
        .background(attributes.background ?? .clear, ignoresSafeAreaEdges: .all)
        .applyPadding(
            size: attributes.contentPadding,
            from: theme
        )
    }
}
