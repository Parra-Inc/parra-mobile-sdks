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

        public internal(set) var background: Color?
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var contentPadding: ParraPaddingSize?
        public internal(set) var padding: ParraPaddingSize?

        public static func `default`(with theme: ParraTheme) -> Widget {
            let palette = theme.palette

            return Widget(
                background: palette.primaryBackground,
                cornerRadius: .zero,
                contentPadding: .custom(
                    EdgeInsets(vertical: 12, horizontal: 20)
                ),
                padding: .zero
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
            contentPadding: overrides?.contentPadding,
            padding: overrides?.padding
        )
    }
}
