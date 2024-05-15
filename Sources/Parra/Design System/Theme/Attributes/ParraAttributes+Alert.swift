//
//  ParraAttributes+Alert.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct InlineAlert: ParraCommonViewAttributes {
        // MARK: - Lifecycle

        public init(
            title: ParraAttributes.Label = .init(),
            subtitle: ParraAttributes.Label = .init(),
            icon: ParraAttributes.Image = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public let title: ParraAttributes.Label
        public let subtitle: ParraAttributes.Label
        public let icon: ParraAttributes.Image

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }

    struct ToastAlert {
        // MARK: - Lifecycle

        public init(
            title: ParraAttributes.Label = .init(),
            subtitle: ParraAttributes.Label = .init(),
            icon: ParraAttributes.Image = .init(),
            dismissButton: ParraAttributes.ImageButton = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.dismissButton = dismissButton
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public let title: ParraAttributes.Label
        public let subtitle: ParraAttributes.Label
        public let icon: ParraAttributes.Image
        public let dismissButton: ParraAttributes.ImageButton

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }
}

// MARK: - ParraAttributes.InlineAlert + OverridableAttributes

extension ParraAttributes.InlineAlert: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.InlineAlert?
    ) -> ParraAttributes.InlineAlert {
        return ParraAttributes.InlineAlert(
            title: title.mergingOverrides(overrides?.title),
            subtitle: subtitle.mergingOverrides(overrides?.subtitle),
            icon: icon.mergingOverrides(overrides?.icon),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}

// MARK: - ParraAttributes.ToastAlert + OverridableAttributes

extension ParraAttributes.ToastAlert: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.ToastAlert?
    ) -> ParraAttributes.ToastAlert {
        return ParraAttributes.ToastAlert(
            title: title.mergingOverrides(overrides?.title),
            subtitle: subtitle.mergingOverrides(overrides?.subtitle),
            icon: icon.mergingOverrides(overrides?.icon),
            dismissButton: dismissButton
                .mergingOverrides(overrides?.dismissButton),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
