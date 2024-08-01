//
//  ParraColorSwatch+ParraColorConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraColorSwatch: ParraColorConvertible {
    public func toParraColor() -> ParraColor {
        return shade500
    }
}
