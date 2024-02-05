//
//  LabelConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal enum LabelType {
    case title
    case description
    case body
}

internal struct LabelConfig {
    internal let type: LabelType

    internal init(type: LabelType) {
        self.type = type
    }
}
