//
//  ParraAttributes+Menu.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Menu

public extension ParraAttributes {
    struct Menu {
        // MARK: - Lifecycle

        public init(
            titleLabel: ParraAttributes.Label = .init(),
            helperLabel: ParraAttributes.Label = .init(),
            selectedMenuItemLabels: ParraAttributes.Label = .init(),
            unselectedMenuItemLabels: ParraAttributes.Label = .init(),
            tint: Color? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.titleLabel = titleLabel
            self.helperLabel = helperLabel
            self.selectedMenuItemLabels = selectedMenuItemLabels
            self.unselectedMenuItemLabels = unselectedMenuItemLabels
            self.tint = tint
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public var titleLabel: ParraAttributes.Label
        public var helperLabel: ParraAttributes.Label
        public var selectedMenuItemLabels: ParraAttributes.Label
        public var unselectedMenuItemLabels: ParraAttributes.Label
        public var tint: Color?
        public var border: ParraAttributes.Border
        public var cornerRadius: ParraCornerRadiusSize?
        public var padding: ParraPaddingSize?
        public var background: Color?
    }
}

// MARK: - ParraAttributes.Menu + OverridableAttributes

extension ParraAttributes.Menu: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Menu?
    ) -> ParraAttributes.Menu {
        return ParraAttributes.Menu(
            titleLabel: titleLabel.mergingOverrides(overrides?.titleLabel),
            helperLabel: helperLabel.mergingOverrides(overrides?.helperLabel),
            selectedMenuItemLabels: selectedMenuItemLabels
                .mergingOverrides(overrides?.selectedMenuItemLabels),
            unselectedMenuItemLabels: unselectedMenuItemLabels
                .mergingOverrides(overrides?.unselectedMenuItemLabels),
            tint: overrides?.tint ?? tint,
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
