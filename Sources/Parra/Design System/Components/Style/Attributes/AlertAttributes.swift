//
//  AlertAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct AlertAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        title: LabelAttributes = .init(),
        subtitle: LabelAttributes = .init(),
        icon: ParraAttributes.Image = .init(),
//        dismiss: ImageButtonAttributes = .init(image: .init()),
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
//        self.dismiss = dismiss
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    public let title: LabelAttributes
    public let subtitle: LabelAttributes
    public let icon: ParraAttributes.Image
//    public let dismiss: ImageButtonAttributes

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let padding: EdgeInsets?
    public let borderWidth: CGFloat?
    public let borderColor: Color?

    // MARK: - Internal

    static func defaultBackground(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        let palette = theme.palette

        return switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade300,
                darkVariant: palette.success.shade900
            )
        case .info:
            palette.primaryBackground
        case .warn:
            Color(
                lightVariant: palette.warning.shade300,
                darkVariant: palette.warning.shade900
            )
        case .error:
            Color(
                lightVariant: palette.error.shade300,
                darkVariant: palette.error.shade900
            )
        }
    }

    static func defaultIconTint(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraColor {
        let palette = theme.palette

        return switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade600,
                darkVariant: palette.success.shade400
            )
        case .info:
            Color(
                lightVariant: ParraColorSwatch.gray.shade600,
                darkVariant: ParraColorSwatch.gray.shade400
            )
        case .warn:
            Color(
                lightVariant: palette.warning.shade600,
                darkVariant: palette.warning.shade400
            )
        case .error:
            Color(
                lightVariant: palette.error.shade600,
                darkVariant: palette.error.shade400
            )
        }
    }

    static func defaultBorder(
        for level: AlertLevel,
        with theme: ParraTheme
    ) -> ParraColor? {
        let palette = theme.palette

        return switch level {
        case .success:
            Color(
                lightVariant: palette.success.shade400,
                darkVariant: palette.success.shade950
            )
        case .info:
            palette.primarySeparator.toParraColor()
        case .warn:
            Color(
                lightVariant: palette.warning.shade400,
                darkVariant: palette.warning.shade950
            )
        case .error:
            Color(
                lightVariant: palette.error.shade400,
                darkVariant: palette.error.shade950
            )
        }
    }
}
