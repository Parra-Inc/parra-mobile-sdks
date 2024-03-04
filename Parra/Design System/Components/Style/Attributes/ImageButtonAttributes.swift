//
//  ImageButtonAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ImageButtonAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        image: ImageAttributes,
        imageDisabled: ImageAttributes? = nil,
        imagePressed: ImageAttributes? = nil
    ) {
        self.image = image
        self.imageDisabled = imageDisabled
        self.imagePressed = imagePressed
    }

    // MARK: - Public

    /// Attributes to use for the button's image in the normal state
    /// (not disabled or selected).
    public let image: ImageAttributes

    /// Attributes to use for the button's image in cases where the button is in
    /// a disabled state. If omitted, defaults based on the
    /// ``ImageButtonAttributes/image`` will be applied.
    public let imageDisabled: ImageAttributes?

    /// Attributes to use for the button's image in cases where the button is in
    /// a pressed state. If omitted, defaults based on the
    /// ``ImageButtonAttributes/image`` will be applied.
    public let imagePressed: ImageAttributes?

    // MARK: - Internal

    static func defaultAttributes(
        for theme: ParraTheme,
        with config: ImageButtonConfig
    ) -> ImageButtonAttributes {
        let palette = theme.palette

        let backgroundColor: Color? = switch config.variant {
        case .plain, .outlined:
            .clear
        case .contained:
            switch config.style {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        }

        let tint: Color = switch config.variant {
        case .plain, .outlined:
            switch config.style {
            case .primary:
                palette.primary.toParraColor()
            case .secondary:
                palette.secondary.toParraColor()
            }
        case .contained:
            palette.primaryBackground.toParraColor()
        }

        let (borderColor, borderWidth): (Color?, CGFloat?) = switch config
            .variant
        {
        case .contained, .plain:
            (nil, nil)
        case .outlined:
            switch config.style {
            case .primary:
                (palette.primary.toParraColor(), 1.5)
            case .secondary:
                (palette.secondary.toParraColor(), 1.5)
            }
        }

        let size = switch config.size {
        case .smallSquare:
            CGSize(width: 20, height: 20)
        case .mediumSquare:
            CGSize(width: 34, height: 34)
        case .largeSquare:
            CGSize(width: 50, height: 50)
        case .custom(let customSize):
            customSize
        }

        let cornerRadius: ParraCornerRadiusSize = switch config.size {
        case .smallSquare, .mediumSquare:
            .small
        case .largeSquare:
            .medium
        case .custom:
            .zero
        }

        let padding = EdgeInsets(
            vertical: (size.height * 0.2).rounded(.down),
            horizontal: (size.width * 0.2).rounded(.down)
        )

        return ImageButtonAttributes(
            image: ImageAttributes(
                background: backgroundColor,
                cornerRadius: cornerRadius,
                tint: tint,
                opacity: 1.0,
                padding: padding,
                frame: .fixed(
                    FixedFrameAttributes(
                        width: size.width,
                        height: size.height
                    )
                ),
                borderWidth: borderWidth,
                borderColor: borderColor
            )
        )
    }
}

extension ImageButtonAttributes {
    func withUpdates(updates: Self?) -> Self {
        let updatedImagePressed: ImageAttributes? = if let imagePressed {
            imagePressed.withUpdates(updates: updates?.imagePressed)
        } else {
            updates?.imagePressed
        }

        let updatedImageDisabled: ImageAttributes? = if let imageDisabled {
            imageDisabled.withUpdates(updates: updates?.imageDisabled)
        } else {
            updates?.imageDisabled
        }

        return ImageButtonAttributes(
            image: image.withUpdates(updates: updates?.image),
            imageDisabled: updatedImagePressed,
            imagePressed: updatedImageDisabled
        )
    }
}
