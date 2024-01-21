//
//  RectangleCornerRadii+Hashable.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension RectangleCornerRadii: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(topLeading)
        hasher.combine(topTrailing)
        hasher.combine(bottomLeading)
        hasher.combine(bottomTrailing)
    }
}
