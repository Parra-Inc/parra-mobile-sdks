//
//  AuthorizationType.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum AuthorizationType {
    case basic(String)
    case bearer(String)

    var value: String {
        switch self {
        case .basic(let token):
            return "Basic \(token)"
        case .bearer(let token):
            return "Bearer \(token)"
        }
    }
}
