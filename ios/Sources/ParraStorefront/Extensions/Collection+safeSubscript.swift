//
//  Collection+safeSubscript.swift
//  Parra
//
//  Created by Mick MacCallum on 2/18/25.
//

import Foundation

extension Collection {
    subscript(
        safe index: Index
    ) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
