//
//  ParraColor+ParraColorSwatchConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraColor: ParraColorSwatchConvertible {
    public func toSwatch() -> ParraColorSwatch {
        return ParraColorSwatch(
            primary: self
        )
    }
}
