//
//  ParraButtonVariant.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraButtonVariant: CustomStringConvertible {
    case plain
    case outlined
    case contained // filled

    var description: String {
        switch self {
        case .plain:
            return "plain"
        case .outlined:
            return "outlined"
        case .contained:
            return "contained"
        }
    }
}
