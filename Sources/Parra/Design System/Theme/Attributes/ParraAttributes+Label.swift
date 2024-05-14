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
    struct Label {
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
        }

        init(
            text: ParraAttributes.Text = .init(),
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = .zero,
            padding: ParraPaddingSize? = .zero,
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

        public internal(set) var text: ParraAttributes.Text
        public internal(set) var icon: ParraAttributes.Image
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?

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
            frame: overrides?.frame ?? frame
        )
    }
}

extension ParraAttributes.Label {
    static func defaultInputTitle(
        for theme: ParraTheme
    ) -> Self {
        let palette = theme.palette

        return ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .body,
                weight: .medium,
                color: palette.primaryText.toParraColor(),
                alignment: .leading
            ),
            padding: .custom(
                .padding(leading: 1, bottom: 8, trailing: 2)
            )
        )
    }

    static func defaultInputHelper(
        for theme: ParraTheme
    ) -> Self {
        let palette = theme.palette

        return ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .caption,
                color: palette.secondaryText.toParraColor(),
                alignment: .trailing
            ),
            padding: .custom(
                .padding(top: 3, bottom: 4, trailing: 2)
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
