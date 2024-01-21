//
//  EdgeInsets+hashable.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension EdgeInsets: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(top)
        hasher.combine(bottom)
        hasher.combine(leading)
        hasher.combine(trailing)
    }
}
