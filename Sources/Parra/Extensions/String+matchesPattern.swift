//
//  String+matchesPattern.swift
//  Parra
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension String {
    func matches(pattern: some RegexComponent) -> Bool {
        return firstMatch(
            of: pattern
        ) != nil
    }
}
