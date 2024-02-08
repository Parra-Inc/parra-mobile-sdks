//
//  View+ApplyAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    func applyCornerRadii(
        size: ParraCornerRadiusSize?,
        from theme: ParraTheme
    ) -> some View {
        return clipShape(
            UnevenRoundedRectangle(
                cornerRadii: theme.cornerRadius.value(
                    for: size ?? .zero
                )
            )
        )
    }

    @ViewBuilder
    func applyBackground(
        _ background: (any ShapeStyle)?
    ) -> some View {
        let style = if let background {
            AnyShapeStyle(background)
        } else {
            AnyShapeStyle(.clear)
        }

        self.background(style)
    }
}
