//
//  View+applyAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyImageAttributes(
        _ attributes: ParraAttributes.Image,
        using theme: ParraTheme
    ) -> some View {
        withFrame(attributes.size)
            .background(attributes.background ?? .clear)
            .applyPadding(
                size: attributes.padding,
                from: theme
            )
            .foregroundStyle(
                attributes.tint ?? .black
            )
            .opacity(attributes.opacity ?? 1.0)
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
    private func withFrame(
        _ size: CGSize?
    ) -> some View {
        if let size {
            frame(width: size.width, height: size.height)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyTextAttributes(
        _ attributes: ParraAttributes.Text,
        using theme: ParraTheme
    ) -> some View {
        font(attributes.font)
            .fontWidth(attributes.width)
            .fontWeight(attributes.weight)
            .fontDesign(attributes.design)
            .foregroundColor(attributes.color)
            .multilineTextAlignment(attributes.alignment ?? .leading)
            .shadow(
                color: attributes.shadow?.color ?? .clear,
                radius: attributes.shadow?.radius ?? 0.0,
                x: attributes.shadow?.x ?? 0.0,
                y: attributes.shadow?.y ?? 0.0
            )
    }

    @ViewBuilder
    func applyLabelAttributes(
        _ attributes: ParraAttributes.Label,
        using theme: ParraTheme
    ) -> some View {
        backgroundStyle(attributes.background ?? .clear)
            .applyCornerRadii(
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

    @ViewBuilder
    func applyPlainButtonAttributes(
        _ attributes: ParraAttributes.PlainButton,
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
        _ attributes: ParraAttributes.OutlinedButton,
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
    func applyContainedButtonAttributes(
        _ attributes: ParraAttributes.ContainedButton,
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
        _ attributes: ParraAttributes.ImageButton,
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
}

extension View {
    @ViewBuilder
    func applyCornerRadii(
        size: ParraCornerRadiusSize?,
        from theme: ParraTheme
    ) -> some View {
        clipShape(
            UnevenRoundedRectangle(
                cornerRadii: theme.cornerRadius.value(
                    for: size ?? .zero
                )
            )
        )
    }

    @ViewBuilder
    func applyPadding(
        size: ParraPaddingSize?,
        from theme: ParraTheme
    ) -> some View {
        padding(
            theme.padding.value(
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
