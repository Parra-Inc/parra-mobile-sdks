//
//  ReleaseType+userFacingString.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ReleaseType {
    var userFacingString: String {
        switch self {
        case .major:
            return "major"
        case .minor:
            return "minor"
        case .patch:
            return "patch"
        case .launch:
            return "launch"
        }
    }
}
