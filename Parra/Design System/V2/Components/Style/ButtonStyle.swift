//
//  ButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ButtonStyle: ComponentStyle {
    /// Styles to use for the button's title in the normal state (not disabled or selected).
    public let title: TextStyle

    /// Styles to use for the button's title in cases where the button is in a disabled state. If omitted, defaults
    /// based on the ``ButtonStyle/title`` will be applied.
    public let titleDisabled: TextStyle?

    /// Styles to use for the button's title in cases where the button is in a pressed state. If omitted, defaults
    /// based on the ``ButtonStyle/title`` will be applied.
    public let titlePressed: TextStyle?

    public let background: (any ShapeStyle)?
    public let cornerRadius: RectangleCornerRadii?
    public let padding: EdgeInsets?

    internal let frame: FrameAttributes?

    public init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        padding: EdgeInsets? = nil,
        title: TextStyle = .init(),
        titleDisabled: TextStyle? = nil,
        titlePressed: TextStyle? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.title = title
        self.titleDisabled = titleDisabled
        self.titlePressed = titlePressed
        self.frame = nil
    }

    internal init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: RectangleCornerRadii? = nil,
        padding: EdgeInsets? = nil,
        title: TextStyle = .init(),
        titleDisabled: TextStyle? = nil,
        titlePressed: TextStyle? = nil,
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

    static func defaultStyles(
        for theme: ParraTheme,
        with config: ButtonConfig
    ) -> ButtonStyle {
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

        let cornerRadius: RectangleCornerRadii = switch size {
        case .small, .medium:
                .init(allCorners: 6)
        case .large:
                .init(allCorners: 8)
        }

        return ButtonStyle(
            cornerRadius: cornerRadius,
            title: TextStyle(
                font: .system(size: fontSize),
                padding: titlePadding
            )
        )
    }
}

extension ButtonStyle {
    internal func withUpdates(updates: Self?) -> Self {
        return ButtonStyle(
            background: updates?.background ?? background,
            cornerRadius: updates?.cornerRadius ?? cornerRadius,
            padding: updates?.padding ?? padding,
            title: title.withUpdates(updates: updates?.title),
            titleDisabled: titleDisabled?.withUpdates(updates: updates?.titleDisabled),
            titlePressed: titlePressed?.withUpdates(updates: updates?.titlePressed),
            frame: updates?.frame ?? frame
        )
    }
}
