//
//  ParraTextValidatorRule.swift
//  Parra
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraTextValidatorRule: CustomStringConvertible {
    case minLength(Int)
    case maxLength(Int)
    case email
    case phone
    case hasUppercase
    case hasLowercase
    case hasNumber
    case hasSpecialCharacter
    case regex(String, failureMessage: String)

    /// A custom validator to be invoked when the text on the associated field
    /// changes. Your validator function should return a Bool indicating whether
    /// the text is valid or not. Optionally specify a failure message to be
    /// included with other validation failure messages, if this rule fails.
    case custom((String) -> Bool, failureMessage: String? = nil)

    // MARK: - Public

    public var description: String {
        switch self {
        case .minLength(let min):
            return "minLength(\(min))"
        case .maxLength(let max):
            return "maxLength(\(max))"
        case .email:
            return "email"
        case .phone:
            return "phone"
        case .hasUppercase:
            return "hasUppercase"
        case .hasLowercase:
            return "hasLowercase"
        case .hasNumber:
            return "hasNumber"
        case .hasSpecialCharacter:
            return "hasSpecialCharacter"
        case .regex(let pattern, _):
            return "regex(\(pattern))"
        case .custom:
            return "custom"
        }
    }
}
