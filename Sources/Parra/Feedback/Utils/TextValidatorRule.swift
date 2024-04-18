//
//  TextValidatorRule.swift
//  Parra
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum TextValidatorRule {
    case minLength(Int)
    case maxLength(Int)
    case email
    case hasUppercase
    case hasLowercase
    case hasNumber
    case hasSpecialCharacter

    /// A custom validator to be invoked when the text on the associated field
    /// changes. Your validator function should return a Bool indicating whether
    /// the text is valid or not. Optionally specify a failure message to be
    /// included with other validation failure messages, if this rule fails.
    case custom((String) -> Bool, failureMessage: String? = nil)
}
