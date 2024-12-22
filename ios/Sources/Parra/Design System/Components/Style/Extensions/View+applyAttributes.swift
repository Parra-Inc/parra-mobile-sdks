//
//  View+applyAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    internal func applyCommonViewAttributes(
        _ attributes: ParraCommonViewAttributes,
        from theme: ParraTheme
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
    func applyCornerRadii(
        size: ParraCornerRadiusSize?,
        from theme: ParraTheme
    ) -> some View {
        // If this isn't present, the clipping can interfere with safe areas/etc
        // on views that don't need a corner radius because they're expected to
        // go up against the edges of the screen.
        if let size, size != .zero {
            clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: theme.cornerRadius.value(
                        for: size
                    )
                )
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func applyPadding(
        size: ParraPaddingSize?,
        on edges: Edge.Set = .all,
        from theme: ParraTheme
    ) -> some View {
        padding(
            edges,
            from: theme.padding.value(
                for: size ?? .zero
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

    func applyOpacity(_ opacity: Double?) -> some View {
        self.opacity(opacity ?? 1.0)
    }

    @ViewBuilder
    func applyBorder(
        borderColor: Color?,
        borderWidth: CGFloat? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        from theme: ParraTheme
    ) -> some View {
        overlay(
            UnevenRoundedRectangle(
                cornerRadii: theme.cornerRadius
                    .value(for: cornerRadius)
            )
            .strokeBorder(
                borderColor ?? .black,
                lineWidth: borderWidth ?? 0
            )
        )
    }

    @ViewBuilder
    func applyBorder(
        _ borderAttributes: ParraAttributes.Border,
        with cornerRadius: ParraCornerRadiusSize? = nil,
        from theme: ParraTheme
    ) -> some View {
        overlay(
            UnevenRoundedRectangle(
                cornerRadii: theme.cornerRadius
                    .value(for: cornerRadius)
            )
            .strokeBorder(
                borderAttributes.color ?? .black,
                lineWidth: borderAttributes.width ?? 0
            )
        )
    }

    @ViewBuilder
    internal func applyFrame(
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
