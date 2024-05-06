//
//  AuthenticationWidgetConfig.swift
//  Tests
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraAuthConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.emailValidationRules = ParraAuthConfig.default
            .emailValidationRules

        self.passwordValidationRules = ParraAuthConfig.default
            .passwordValidationRules
    }

    public init(
        emailValidationRules: [TextValidatorRule] = ParraAuthConfig.default
            .emailValidationRules,
        passwordValidationRules: [TextValidatorRule] = ParraAuthConfig.default
            .passwordValidationRules
    ) {
        self.emailValidationRules = emailValidationRules
        self.passwordValidationRules = passwordValidationRules
    }

    // MARK: - Public

    public static let `default` = ParraAuthConfig(
        emailValidationRules: [
            .minLength(5),
            .maxLength(128),
            .email
        ],
        passwordValidationRules: [
            .minLength(8),
            .maxLength(256),
            .hasLowercase,
            .hasUppercase
        ]
    )

    public let emailValidationRules: [TextValidatorRule]
    public let passwordValidationRules: [TextValidatorRule]
}

// public static let `default` = ParraAuthConfig(
//    title: LabelConfig(fontStyle: .largeTitle),
//    subtitle: LabelConfig(fontStyle: .subheadline),
//    emailField: TextInputConfig(
//        title: LabelConfig(fontStyle: .subheadline),
//        helper: LabelConfig(fontStyle: .caption),
//        validationRules: [
//            .minLength(5),
//            .maxLength(128),
//            .email
//        ],
//        preferValidationErrorsToHelperMessage: true
//    ),
//    passwordField: TextInputConfig(
//        title: LabelConfig(fontStyle: .subheadline),
//        helper: LabelConfig(fontStyle: .caption),
//        validationRules: [
//            .minLength(8),
//            .maxLength(256),
//            .hasLowercase,
//            .hasUppercase
//        ],
//        preferValidationErrorsToHelperMessage: true,
//        isSecure: true
//    ),
//    loginButton: TextButtonConfig(
//        style: .primary, size: .large, isMaxWidth: true
//    ),
//    signupButton: TextButtonConfig(
//        style: .primary, size: .small, isMaxWidth: false
//    ),
//    signupConfirmButton: TextButtonConfig(
//        style: .primary, size: .large, isMaxWidth: true
//    ),
//    loginErrorLabel: LabelConfig(
//        fontStyle: .caption
//    )
//    )
