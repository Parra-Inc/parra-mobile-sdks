//
//  TextValidator.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

enum TextValidatorRule {
    case minLength(Int)
    case maxLength(Int)
}

struct TextValidator {
    static func isValid(
        text: String,
        against rule: TextValidatorRule
    ) -> Bool {
        switch rule {
        case .minLength(let min):
            return text.count >= min
        case .maxLength(let max):
            return text.count <= max
        }
    }


    /// Validates the supplied text against the provided rules. If there is an error, a human readable message
    /// is returned. If there is no error, nil is returned. This will only return a message for the first error
    /// that is encountered.
    static func validate(
        text: String?,
        against rules: [TextValidatorRule]
    ) -> String? {
        guard let text, !text.isEmpty else {
            return "must not be empty"
        }

        for rule in rules {
            let valid = isValid(text: text, against: rule)

            switch (valid, rule) {
            case (false, .minLength(let min)):
                let chars = min.simplePluralized(singularString: "character")

                return "must have at least \(min) \(chars)"
            case (false, .maxLength(let max)):
                let chars = max.simplePluralized(singularString: "character")

                return "must have at most \(max) \(chars)"
            default:
                continue
            }
        }

        return nil
    }
}
