//
//  WidgetStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct WidgetStyle: ContainerStyle {
    var background: (any ShapeStyle)?
    var contentPadding: EdgeInsets
    var cornerRadius: ParraCornerRadiusSize
    var padding: EdgeInsets
}
