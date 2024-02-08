//
//  ButtonVariant.swift
//  Parra
//
//  Created by Mick MacCallum on 2/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum ButtonVariant: CustomStringConvertible {
    case plain
    case outlined
    case contained // filled

    // MARK: Internal

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
