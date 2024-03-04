//
//  ImageButtonConfig+Size.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension ImageButtonConfig {
    enum Size {
        case smallSquare
        case mediumSquare
        case largeSquare
        case custom(CGSize)
    }
}
