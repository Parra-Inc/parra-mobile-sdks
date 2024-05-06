//
//  Attributes+Shadow.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct Shadow {
        // MARK: - Lifecycle

        public init(
            color: Color,
            radius: CGFloat = 0.0,
            x: CGFloat = 0.0,
            y: CGFloat = 0.0
        ) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }

        // MARK: - Public

        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
    }
}
