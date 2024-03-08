//
//  ParraCornerRadiusSize.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraCornerRadiusSize: Hashable, Equatable {
    case zero // name "zero" is unambiguous with Optional.none in cases where this is nil
    case xs
    case sm
    case md
    case lg
    case xl
}
