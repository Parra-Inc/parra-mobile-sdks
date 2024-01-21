//
//  ContainerStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol ContainerStyle {
    var background: ParraBackground { get }
    var contentPadding: EdgeInsets { get }
}
