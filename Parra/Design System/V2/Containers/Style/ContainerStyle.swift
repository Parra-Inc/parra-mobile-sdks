//
//  ContainerStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ContainerStyle {
    var background: (any ShapeStyle)? { get }
    var contentPadding: EdgeInsets { get }
}
