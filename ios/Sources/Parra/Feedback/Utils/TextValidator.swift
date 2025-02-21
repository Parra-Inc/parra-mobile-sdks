//
//  TextValidator.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger()

enum TextValidator {
    static func isValid(
        text: String?,
        against rule: ParraTextValidatorRule
    ) throws -> Bool {
        guard let text else {
            return false
        }

        switch rule {
        case .minLength(let min):
            return text.count >= min
        case .maxLength(let max):
            return text.count <= max
        case .email:
            return text.matches(
                pattern: /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/
            )
        case .phone:
            return text.matches(
                pattern: /^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/
            )
        case .hasUppercase:
            return text.matches(
                pattern: /^.*[A-Z]+.*$/
            )
        case .hasLowercase:
            return text.matches(
                pattern: /^.*[a-z]+.*$/
            )
        case .hasNumber:
            return text.matches(
                pattern: /^.*[0-9]+.*$/
            )
        case .hasSpecialCharacter:
            return text.matches(
                pattern: /^(?=.*[^a-zA-Z0-9])$/
            )
        case .regex(let pattern, _):
            return try text.matches(
                pattern: Regex(pattern)
            )
        case .custom(let validator, _):
            return validator(text)
        }
    }

    static func isValid(
        text: String?,
        against rules: [ParraTextValidatorRule]
    ) throws -> Bool {
        return try rules.allSatisfy {
            try isValid(text: text, against: $0)
        }
    }

    /// Validates the supplied text against the provided rules. If there is an
    /// error, a human readable message is returned. If there is no error, nil
    /// is returned. This will only return a message for the first error that
    /// is encountered.
    static func validate(
        text: String?,
        against rules: [ParraTextValidatorRule]
    ) -> String? {
        for rule in rules {
            do {
                let valid = try isValid(text: text ?? "", against: rule)

                switch (valid, rule) {
                case (false, .minLength(let min)):
                    if let text, text.isEmpty {
                        return "must not be empty"
                    } else {
                        let chars = min
                            .simplePluralized(singularString: "character")

                        return "must have at least \(min) \(chars)"
                    }
                case (false, .maxLength(let max)):
                    let chars = max
                        .simplePluralized(singularString: "character")

                    return "must have at most \(max) \(chars)"
                case (false, .email):
                    return "must be a valid email address"
                case (false, .hasUppercase):
                    return "must have at least one uppercase letter"
                case (false, .hasLowercase):
                    return "must have at least one lowercase letter"
                case (false, .hasNumber):
                    return "must have at least one number"
                case (false, .hasSpecialCharacter):
                    return "must have at least one special character"
                case (false, .custom(_, let failureMessage)):
                    if let failureMessage {
                        return failureMessage
                    }
                default:
                    continue
                }
            } catch {
                logger.error("Error validating text", error, [
                    "text": text ?? "unknown",
                    "rules": rules.map { rule in
                        rule.description
                    }.joined()
                ])
            }
        }

        return nil
    }
}
