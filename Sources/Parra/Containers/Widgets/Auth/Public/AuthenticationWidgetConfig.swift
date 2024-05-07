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

        self.appIcon = ParraAuthConfig.default.appIcon
    }

    public init(
        emailValidationRules: [TextValidatorRule] = ParraAuthConfig.default
            .emailValidationRules,
        passwordValidationRules: [TextValidatorRule] = ParraAuthConfig.default
            .passwordValidationRules,
        appIcon: ParraImageContent?
    ) {
        self.emailValidationRules = emailValidationRules
        self.passwordValidationRules = passwordValidationRules
        self.appIcon = appIcon
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
        ],
        appIcon: nil
    )

    public let emailValidationRules: [TextValidatorRule]
    public let passwordValidationRules: [TextValidatorRule]

    public let appIcon: ParraImageContent?
}
