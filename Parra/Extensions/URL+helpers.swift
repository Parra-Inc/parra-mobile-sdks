//
//  URL+helpers.swift
//  Parra
//
//  Created by Mick MacCallum on 8/27/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal extension URL {
    func lastComponents(max: Int = 3) -> String {
        return pathComponents.suffix(max).joined(separator: "/")
    }
}
