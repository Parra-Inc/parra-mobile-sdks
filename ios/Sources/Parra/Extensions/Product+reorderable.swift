//
//  Product+reorderable.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

extension Product: Reorderable {
    public var orderElement: String {
        id
    }
}
