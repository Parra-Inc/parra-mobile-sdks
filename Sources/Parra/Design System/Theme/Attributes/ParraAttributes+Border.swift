//
//  ParraAttributes+Border.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.Border

public extension ParraAttributes {
    struct Border {
        // MARK: - Lifecycle

        public init(
            width: CGFloat? = nil,
            color: Color? = nil
        ) {
            self.width = width
            self.color = color
        }

        // MARK: - Public

        public let width: CGFloat?
        public let color: Color?
    }
}

// MARK: - ParraAttributes.Border + OverridableAttributes

extension ParraAttributes.Border: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Border?
    ) -> ParraAttributes.Border {
        ParraAttributes.Border(
            width: overrides?.width ?? width,
            color: overrides?.color ?? color
        )
    }
}
