//
//  ParraAttributes+Widget.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Widget

public extension ParraAttributes {
    struct Widget {
        // MARK: - Public

        public var background: Color?
        public var cornerRadius: ParraCornerRadiusSize?
        public var contentPadding: ParraPaddingSize?

        public static func `default`(with theme: ParraTheme) -> Widget {
            let palette = theme.palette

            return Widget(
                background: palette.primaryBackground,
                cornerRadius: .zero,
                contentPadding: .custom(
                    EdgeInsets(top: 34, leading: 20, bottom: 12, trailing: 20)
                )
            )
        }

        // MARK: - Internal

        func withoutContentPadding() -> Widget {
            var copy = self
            copy.contentPadding = .zero
            return copy
        }
    }
}

// MARK: - ParraAttributes.Widget + OverridableAttributes

extension ParraAttributes.Widget: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Widget?
    ) -> ParraAttributes.Widget {
        return ParraAttributes.Widget(
            background: overrides?.background ?? background,
            cornerRadius: overrides?.cornerRadius,
            contentPadding: overrides?.contentPadding
        )
    }
}
