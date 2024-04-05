//
//  UIColor+ParraColorSwatchConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

extension UIColor: ParraColorSwatchConvertible {
    public func toSwatch() -> ParraColorSwatch {
        return ParraColorSwatch(
            primary: Color(self)
        )
    }
}
