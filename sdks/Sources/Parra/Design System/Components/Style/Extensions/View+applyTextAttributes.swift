//
//  View+applyTextAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyTextAttributes(
        _ attributes: ParraAttributes.Text,
        using theme: ParraTheme
    ) -> some View {
        font(attributes.fontType.font)
            .foregroundColor(
                attributes.color ?? theme.palette.primaryText.toParraColor()
            )
            .multilineTextAlignment(attributes.alignment ?? .leading)
            .shadow(
                color: attributes.shadow.color ?? .clear,
                radius: attributes.shadow.radius ?? 0.0,
                x: attributes.shadow.x ?? 0.0,
                y: attributes.shadow.y ?? 0.0
            )
    }
}
