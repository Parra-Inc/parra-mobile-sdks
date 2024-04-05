//
//  TextButtonAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct TextButtonAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        title: LabelAttributes = .init(),
        titleDisabled: LabelAttributes? = nil,
        titlePressed: LabelAttributes? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.title = title
        self.titleDisabled = titleDisabled
        self.titlePressed = titlePressed
        self.frame = nil
    }

    init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        title: LabelAttributes = .init(),
        titleDisabled: LabelAttributes? = nil,
        titlePressed: LabelAttributes? = nil,
        frame: FrameAttributes? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.title = title
        self.titleDisabled = titleDisabled
        self.titlePressed = titlePressed
        self.frame = frame
    }

    // MARK: - Public

    /// Attributes to use for the button's title in the normal state (not disabled or selected).
    public let title: LabelAttributes

    /// Attributes to use for the button's title in cases where the button is in a disabled state. If omitted, defaults
    /// based on the ``ButtonAttributes/title`` will be applied.
    public let titleDisabled: LabelAttributes?

    /// Attributes to use for the button's title in cases where the button is in a pressed state. If omitted, defaults
    /// based on the ``ButtonAttributes/title`` will be applied.
    public let titlePressed: LabelAttributes?

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let padding: EdgeInsets?

    // MARK: - Internal

    let frame: FrameAttributes?

    static func defaultAttributes(
        for theme: ParraTheme,
        with config: TextButtonConfig
    ) -> TextButtonAttributes {
        let size = config.size

        let lineHeight: CGFloat = switch size {
        case .small:
            20.0
        case .medium:
            24.0
        case .large:
            28.0
        }

        let fontSize: CGFloat = switch size {
        case .small:
            14.0
        case .medium:
            16.0
        case .large:
            18.0
        }

        let extraVerticalPadding = ((lineHeight - fontSize) / 2.0).rounded()
        let titlePadding: EdgeInsets = switch size {
        case .small:
            .init(vertical: 4 + extraVerticalPadding, horizontal: 8)
        case .medium:
            .init(vertical: 6 + extraVerticalPadding, horizontal: 10)
        case .large:
            .init(vertical: 10 + extraVerticalPadding, horizontal: 12)
        }

        let cornerRadius: ParraCornerRadiusSize = switch size {
        case .small, .medium:
            .sm
        case .large:
            .md
        }

        return TextButtonAttributes(
            cornerRadius: cornerRadius,
            title: LabelAttributes(
                font: Font.system(size: fontSize),
                padding: titlePadding
            )
        )
    }
}

extension TextButtonAttributes {
    func withUpdates(updates: Self?) -> Self {
        let updatedTitlePressed: LabelAttributes? = if let titlePressed {
            titlePressed.withUpdates(updates: updates?.titlePressed)
        } else {
            updates?.titlePressed
        }

        let updatedTitleDisabled: LabelAttributes? = if let titleDisabled {
            titleDisabled.withUpdates(updates: updates?.titleDisabled)
        } else {
            updates?.titleDisabled
        }

        return TextButtonAttributes(
            background: updates?.background ?? background,
            cornerRadius: updates?.cornerRadius ?? cornerRadius,
            padding: updates?.padding ?? padding,
            title: title.withUpdates(updates: updates?.title),
            titleDisabled: updatedTitleDisabled,
            titlePressed: updatedTitlePressed,
            frame: updates?.frame ?? frame
        )
    }
}
