//
//  ParraAttributes+Shadow.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Shadow

public extension ParraAttributes {
    struct Shadow {
        // MARK: - Lifecycle

        public init(
            color: Color? = nil,
            radius: CGFloat? = nil,
            x: CGFloat? = nil,
            y: CGFloat? = nil
        ) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }

        // MARK: - Public

        public let color: Color?
        public let radius: CGFloat?
        public let x: CGFloat?
        public let y: CGFloat?
    }
}

// MARK: - ParraAttributes.Shadow + OverridableAttributes

extension ParraAttributes.Shadow: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Shadow?
    ) -> ParraAttributes.Shadow {
        return ParraAttributes.Shadow(
            color: overrides?.color ?? color,
            radius: overrides?.radius ?? radius,
            x: overrides?.x ?? x,
            y: overrides?.y ?? y
        )
    }
}
