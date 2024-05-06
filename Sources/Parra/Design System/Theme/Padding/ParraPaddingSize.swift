//
//  ParraPaddingSize.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraPaddingSize: Hashable, Equatable {
    case zero
    case xs
    case sm
    case md
    case lg
    case xl
    case xxl
    case xxxl
    case custom(EdgeInsets)
}
