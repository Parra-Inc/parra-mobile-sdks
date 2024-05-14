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
    struct Menu: ParraCommonViewAttributes {
        // MARK: - Lifecycle

        public init(
            titleLabel: ParraAttributes.Label = .init(),
            helperLabel: ParraAttributes.Label = .init(),
            selectedMenuItemLabels: ParraAttributes.Label = .init(),
            unselectedMenuItemLabels: ParraAttributes.Label = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.titleLabel = titleLabel
            self.helperLabel = helperLabel
            self.selectedMenuItemLabels = selectedMenuItemLabels
            self.unselectedMenuItemLabels = unselectedMenuItemLabels
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public internal(set) var titleLabel: ParraAttributes.Label
        public internal(set) var helperLabel: ParraAttributes.Label
        public internal(set) var selectedMenuItemLabels: ParraAttributes.Label
        public internal(set) var unselectedMenuItemLabels: ParraAttributes.Label
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
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
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
