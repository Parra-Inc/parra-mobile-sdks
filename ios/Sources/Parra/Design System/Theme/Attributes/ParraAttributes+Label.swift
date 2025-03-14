//
//  ParraAttributes+Label.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Label

public extension ParraAttributes {
    struct Label: ParraCommonViewAttributes {
        // MARK: - Lifecycle

        public init(
            text: ParraAttributes.Text = .init(),
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.frame = nil
        }

        init(
            text: ParraAttributes.Text = .init(),
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil,
            frame: FrameAttributes? = nil
        ) {
            self.text = text
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
            self.frame = frame
        }

        // MARK: - Public

        public var text: ParraAttributes.Text
        public var icon: ParraAttributes.Image
        public var border: ParraAttributes.Border
        public var cornerRadius: ParraCornerRadiusSize?
        public var padding: ParraPaddingSize?
        public var background: Color?

        // MARK: - Internal

        var frame: FrameAttributes?
    }
}

// MARK: - ParraAttributes.Label + OverridableAttributes

extension ParraAttributes.Label: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Label?
    ) -> ParraAttributes.Label {
        ParraAttributes.Label(
            text: text.mergingOverrides(overrides?.text),
            icon: icon.mergingOverrides(overrides?.icon),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background,
            frame: frame?.mergingOverrides(overrides?.frame) ?? overrides?.frame
        )
    }
}

extension ParraAttributes.Label {
    public static func `default`(
        with style: Font.TextStyle,
        width: Font.Width? = nil,
        weight: Font.Weight? = nil,
        design: Font.Design? = nil,
        color: Color? = nil,
        alignment: TextAlignment? = nil,
        shadow: ParraAttributes.Shadow = .init()
    ) -> ParraAttributes.Label {
        return ParraAttributes.Label(
            text: ParraAttributes.Text(
                style: style,
                width: width,
                weight: weight,
                design: design,
                color: color,
                alignment: alignment,
                shadow: shadow
            )
        )
    }

    static func defaultInputTitle(
        for theme: ParraTheme
    ) -> Self {
        let palette = theme.palette

        return ParraAttributes.Label(
            text: ParraAttributes.Text(
                fontType: .style(
                    style: .headline,
                    weight: .regular
                ),
                color: palette.primaryText.toParraColor(),
                alignment: .leading
            ),
            padding: .custom(
                .padding(leading: 2, bottom: 6, trailing: 2)
            )
        )
    }

    static func defaultInputHelper(
        for theme: ParraTheme
    ) -> Self {
        let palette = theme.palette

        return ParraAttributes.Label(
            text: ParraAttributes.Text(
                style: .caption2,
                color: palette.secondaryText.toParraColor(),
                alignment: .trailing
            ),
            padding: .custom(
                .padding(top: 4, bottom: 4, trailing: 2)
            ),
            frame: .flexible(
                FlexibleFrameAttributes(
                    maxWidth: .infinity,
                    minHeight: 12,
                    idealHeight: 12,
                    maxHeight: 12,
                    alignment: .trailing
                )
            )
        )
    }
}
