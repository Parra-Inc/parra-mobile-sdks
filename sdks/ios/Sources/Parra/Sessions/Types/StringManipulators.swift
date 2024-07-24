//
//  StringManipulators.swift
//  Tests
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

enum StringManipulators {
    static let hyphenAndSpaceCharset: CharacterSet = .whitespacesAndNewlines
        .union(.init(charactersIn: "-"))

    static func snakeCaseify(text: String) -> String {
        return text.components(
            separatedBy: StringManipulators.hyphenAndSpaceCharset
        ).joined(separator: "_")
    }
}
