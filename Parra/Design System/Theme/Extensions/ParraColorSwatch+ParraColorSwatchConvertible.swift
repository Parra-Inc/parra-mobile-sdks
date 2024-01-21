//
//  ParraColorSwatch+ParraColorSwatchConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraColorSwatch: ParraColorSwatchConvertible {
    public func toSwatch() -> ParraColorSwatch {
        return self
    }
}
