//
//  ParraAttributes+Segment.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Segment

public extension ParraAttributes {
    struct Segment {
        // MARK: - Lifecycle

        public init(
            selectedOptionLabels: ParraAttributes.Label = .init(),
            unselectedOptionLabels: ParraAttributes.Label = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.selectedOptionLabels = selectedOptionLabels
            self.unselectedOptionLabels = unselectedOptionLabels
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public let selectedOptionLabels: ParraAttributes.Label
        public let unselectedOptionLabels: ParraAttributes.Label

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }
}

// MARK: - ParraAttributes.Segment + OverridableAttributes

extension ParraAttributes.Segment: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Segment?
    ) -> ParraAttributes.Segment {
        return ParraAttributes.Segment(
            selectedOptionLabels: selectedOptionLabels.mergingOverrides(
                overrides?.selectedOptionLabels
            ),
            unselectedOptionLabels: unselectedOptionLabels.mergingOverrides(
                overrides?.unselectedOptionLabels
            ),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
