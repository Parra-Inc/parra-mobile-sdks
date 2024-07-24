//
//  RectangleCornerRadii+shortcuts.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension RectangleCornerRadii {
    init(allCorners: CGFloat) {
        self.init(
            topLeading: allCorners,
            bottomLeading: allCorners,
            bottomTrailing: allCorners,
            topTrailing: allCorners
        )
    }

    static let zero = RectangleCornerRadii(allCorners: 0)
}
