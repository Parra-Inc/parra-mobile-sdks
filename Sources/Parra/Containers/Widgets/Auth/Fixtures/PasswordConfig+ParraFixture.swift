//
//  PasswordConfig+ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension PasswordConfig: ParraFixture {
    static func validStates() -> [PasswordConfig] {
        return [
            PasswordConfig(
                iosPasswordRulesDescriptor: "required: upper, lower, digit; minlength: 8; maxlength: 128;",
                rules: [
                    PasswordRule(
                        regularExpression: "/^(?=.{8,128}$)/",
                        errorMessage: "between 8 and 128 characters"
                    ),
                    PasswordRule(
                        regularExpression: "/^(?=.*[A-Z])/",
                        errorMessage: "at least one uppercase letter"
                    ),
                    PasswordRule(
                        regularExpression: "/^(?=.*[a-z])/",
                        errorMessage: "at least one lowercase letter"
                    ),
                    PasswordRule(
                        regularExpression: "/^(?=.*\\\\d)/",
                        errorMessage: "at least one number"
                    )
                ]
            )
        ]
    }

    static func invalidStates() -> [PasswordConfig] {
        return []
    }
}
