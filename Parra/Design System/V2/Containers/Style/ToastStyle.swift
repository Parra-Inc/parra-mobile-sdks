//
//  ToastStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ToastStyle: ContainerStyle {
    var background: ParraBackground
    var contentPadding: EdgeInsets
    var cornerRadius: RectangleCornerRadii

    // TODO: Position enum
    // TODO: Animation and auto dismiss durations
}
