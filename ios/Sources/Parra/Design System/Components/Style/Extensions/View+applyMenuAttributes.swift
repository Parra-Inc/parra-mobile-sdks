//
//  View+applyMenuAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyMenuAttributes(
        _ attributes: ParraAttributes.Menu,
        using theme: ParraTheme
    ) -> some View {
        background(attributes.background ?? .clear)
            .applyCornerRadii(
                size: attributes.cornerRadius,
                from: theme
            )
            .applyBorder(
                attributes.border,
                with: attributes.cornerRadius,
                from: theme
            )
            .tint(attributes.tint)
    }
}
