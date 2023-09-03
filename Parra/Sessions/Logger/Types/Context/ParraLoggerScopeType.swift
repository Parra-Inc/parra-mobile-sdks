//
//  ParraLoggerScopeType.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraLoggerScopeType: Equatable {
    case customName(String)
    case function(String)

    var name: String {
        switch self {
        case .customName(let string):
            return string
        case .function(let string):
            let components = string.split(separator: "(")

            guard let first = components.first else {
                return string
            }

            return String(first)
        }
    }

    static func == (lhs: ParraLoggerScopeType, rhs: ParraLoggerScopeType) -> Bool {
        switch (lhs, rhs) {
        case (.customName(let lhsName), .customName(let rhsName)):
            return lhsName == rhsName
        case (.function(let lhsFunction), .function(let rhsFunction)):
            return lhsFunction == rhsFunction
        default:
            return false
        }
    }
}
