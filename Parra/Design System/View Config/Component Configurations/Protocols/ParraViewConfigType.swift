//
//  ParraViewConfigType.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// Common fields for all view config types.
public protocol ParraViewConfigType {
    var background: ParraBackground? { get }
    var cornerRadius: RectangleCornerRadii? { get }
    var padding: EdgeInsets? { get }
}
