//
//  UIColor+ParraColorConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension UIColor: ParraColorConvertible {
    public func toParraColor() -> ParraColor {
        return ParraColor(uiColor: self)
    }
}
