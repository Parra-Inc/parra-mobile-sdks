//
//  Attributes+Border.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

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
