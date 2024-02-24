//
//  ToastStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ToastStyle: ContainerStyle {
    var cornerRadius: ParraCornerRadiusSize { get }

    // TODO: Position enum
    // TODO: Animation and auto dismiss durations
}
