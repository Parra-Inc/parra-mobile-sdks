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
        _ cornerRadii: RectangleCornerRadii?
    ) -> some View {
        return clipShape(
            UnevenRoundedRectangle(cornerRadii: cornerRadii ?? .zero)
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
