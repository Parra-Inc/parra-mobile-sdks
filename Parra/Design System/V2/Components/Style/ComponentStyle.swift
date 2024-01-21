//
//  ComponentStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol ComponentStyle {
    var background: (any ShapeStyle)? { get }
    var cornerRadius: RectangleCornerRadii? { get }
    var padding: EdgeInsets? { get }
    var frame: FrameAttributes? { get }

    func withUpdates(updates: Self?) -> Self
}
