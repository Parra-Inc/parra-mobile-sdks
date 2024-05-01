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
        self.title = ParraAuthConfig.default.title
        self.subtitle = ParraAuthConfig.default.subtitle
        self.emailField = ParraAuthConfig.default.emailField
        self.passwordField = ParraAuthConfig.default.passwordField
        self.loginButton = ParraAuthConfig.default.loginButton
        self.signupButton = ParraAuthConfig.default.signupButton
        self.signupConfirmButton = ParraAuthConfig.default.signupConfirmButton
        self.loginErrorLabel = ParraAuthConfig.default.loginErrorLabel
    }

    public init(
        title: LabelConfig = ParraAuthConfig.default.title,
        subtitle: LabelConfig = ParraAuthConfig.default.subtitle,
        emailField: TextInputConfig = ParraAuthConfig.default
            .emailField,
        passwordField: TextInputConfig = ParraAuthConfig.default
            .passwordField,
        loginButton: TextButtonConfig = ParraAuthConfig.default
            .loginButton,
        signupButton: TextButtonConfig = ParraAuthConfig.default
            .signupButton,
        signupConfirmButton: TextButtonConfig = ParraAuthConfig.default
            .signupConfirmButton,
        loginErrorLabel: LabelConfig = ParraAuthConfig.default.loginErrorLabel
    ) {
        self.title = title
        self.subtitle = subtitle
        self.emailField = emailField
        self.passwordField = passwordField
        self.loginButton = loginButton
        self.signupButton = signupButton
        self.signupConfirmButton = signupConfirmButton
        self.loginErrorLabel = loginErrorLabel
    }

    // MARK: - Public

    public static let `default` = ParraAuthConfig(
        title: LabelConfig(fontStyle: .largeTitle),
        subtitle: LabelConfig(fontStyle: .subheadline),
        emailField: TextInputConfig(
            title: LabelConfig(fontStyle: .subheadline),
            helper: LabelConfig(fontStyle: .caption),
            validationRules: [
                .minLength(5),
                .maxLength(128),
                .email
            ],
            preferValidationErrorsToHelperMessage: true
        ),
        passwordField: TextInputConfig(
            title: LabelConfig(fontStyle: .subheadline),
            helper: LabelConfig(fontStyle: .caption),
            validationRules: [
                .minLength(8),
                .maxLength(256),
                .hasLowercase,
                .hasUppercase
            ],
            preferValidationErrorsToHelperMessage: true,
            isSecure: true
        ),
        loginButton: TextButtonConfig(
            style: .primary, size: .large, isMaxWidth: true
        ),
        signupButton: TextButtonConfig(
            style: .primary, size: .small, isMaxWidth: false
        ),
        signupConfirmButton: TextButtonConfig(
            style: .primary, size: .large, isMaxWidth: true
        ),
        loginErrorLabel: LabelConfig(
            fontStyle: .caption
        )
    )

    public let title: LabelConfig
    public let subtitle: LabelConfig

    public let emailField: TextInputConfig
    public let passwordField: TextInputConfig

    public let loginButton: TextButtonConfig
    public let signupButton: TextButtonConfig
    public let signupConfirmButton: TextButtonConfig

    public let loginErrorLabel: LabelConfig
}
