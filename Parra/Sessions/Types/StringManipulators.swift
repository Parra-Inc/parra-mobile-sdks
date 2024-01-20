//
//  StringManipulators.swift
//  ParraTests
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct StringManipulators {
    static let hyphenAndSpaceCharset: CharacterSet = .whitespacesAndNewlines.union(.init(charactersIn: "-"))

    static func snakeCaseify(text: String) -> String {
        return text.components(
            separatedBy: StringManipulators.hyphenAndSpaceCharset
        ).joined(separator: "_")
    }
}
