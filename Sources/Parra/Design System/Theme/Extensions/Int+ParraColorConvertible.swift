//
//  Int+ParraColorConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Int: ParraColorConvertible {
    public func toParraColor() -> ParraColor {
        return ParraColor(hex: self)
    }
}
