//
//  String+randomEmoji.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension String {
    static func randomEmoji() -> String? {
        guard let element = Array(0x1F300 ... 0x1F3F0).randomElement() else {
            return nil
        }

        guard let scalar = UnicodeScalar(element) else {
            return nil
        }

        return String(scalar)
    }
}
