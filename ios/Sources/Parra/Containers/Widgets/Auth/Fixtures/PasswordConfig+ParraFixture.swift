//
//  PasswordConfig+ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraPasswordConfig: ParraFixture {
    static func validStates() -> [ParraPasswordConfig] {
        return [
            ParraPasswordConfig(
                iosPasswordRulesDescriptor: "required: upper, lower, digit; minlength: 8; maxlength: 128;",
                rules: [
                    ParraPasswordRule(
                        regularExpression: "^.{8,128}$",
                        errorMessage: "between 8 and 128 characters"
                    ),
                    ParraPasswordRule(
                        regularExpression: "^.*[A-Z]+.*$",
                        errorMessage: "at least one uppercase letter"
                    ),
                    ParraPasswordRule(
                        regularExpression: "^.*[a-z]+.*$",
                        errorMessage: "at least one lowercase letter"
                    ),
                    ParraPasswordRule(
                        regularExpression: "^.*[0-9]+.*$",
                        errorMessage: "at least one number"
                    )
                ]
            )
        ]
    }

    static func invalidStates() -> [ParraPasswordConfig] {
        return []
    }
}
