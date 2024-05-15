//
//  ParraGlobalComponentAttributes+ImageButton.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func imageButtonAttributes(
        config: ParraImageButtonConfig,
        localAttributes: ParraAttributes.ImageButton?,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton {
        let size = config.size
        let type = config.type
        let variant = config.variant
        let palette = theme.palette

        let backgroundColor: Color? = switch variant {
        case .plain, .outlined:
            .clear
        case .contained:
            switch type {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        }

        let tint: Color = switch variant {
        case .plain, .outlined:
            switch type {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        case .contained:
            palette.primaryBackground.toParraColor()
        }

        let (borderColor, borderWidth): (Color?, CGFloat?) = switch variant {
        case .contained, .plain:
            (nil, nil)
        case .outlined:
            switch type {
            case .primary:
                (palette.primary.toParraColor(), 1.5)
            case .secondary:
                (palette.secondary.toParraColor(), 1.5)
            }
        }

        let frameSize = switch size {
        case .smallSquare:
            CGSize(width: 20, height: 20)
        case .mediumSquare:
            CGSize(width: 34, height: 34)
        case .largeSquare:
            CGSize(width: 50, height: 50)
        case .custom(let customSize):
            customSize
        }

        let padding = EdgeInsets(
            vertical: (frameSize.height * 0.2).rounded(.down),
            horizontal: (frameSize.width * 0.2).rounded(.down)
        )

        let cornerRadius: ParraCornerRadiusSize = switch size {
        case .smallSquare, .mediumSquare:
            .sm
        case .largeSquare:
            .md
        case .custom:
            .zero
        }

        let border = ParraAttributes.Border(
            width: borderWidth,
            color: borderColor
        )

        return ParraAttributes.ImageButton(
            normal: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint,
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            ),
            pressed: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint.opacity(0.8),
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            ),
            disabled: ParraAttributes.ImageButton.StatefulAttributes(
                image: ParraAttributes.Image(
                    tint: tint.opacity(0.6),
                    size: frameSize,
                    border: border,
                    cornerRadius: cornerRadius,
                    padding: .custom(padding),
                    background: backgroundColor
                ),
                border: ParraAttributes.Border(),
                cornerRadius: .zero,
                padding: .sm
            )
        ).mergingOverrides(localAttributes)
    }
}
