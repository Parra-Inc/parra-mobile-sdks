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

    @ViewBuilder
    func applyFrame(
        _ attributes: FrameAttributes?
    ) -> some View {
        switch attributes {
        case .fixed(let frame):
            self.frame(
                width: frame.width,
                height: frame.height,
                alignment: frame.alignment
            )
        case .flexible(let frame):
            self.frame(
                minWidth: frame.minWidth,
                idealWidth: frame.idealWidth,
                maxWidth: frame.maxWidth,
                minHeight: frame.minHeight,
                idealHeight: frame.idealHeight,
                maxHeight: frame.maxHeight,
                alignment: frame.alignment
            )
        case nil:
            self
        }
    }
}
