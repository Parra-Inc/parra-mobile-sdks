//
//  String+prefixes.swift
//  Parra
//
//  Created by Mick MacCallum on 9/16/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal extension String {
    func hasAnyPrefix(_ prefixes: [String]) -> Bool {
        // eventually this could be less naive
        return prefixes.contains { prefix in
            hasPrefix(prefix)
        }
    }
}
