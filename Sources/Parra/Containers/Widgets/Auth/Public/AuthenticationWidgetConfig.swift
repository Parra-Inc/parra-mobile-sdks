//
//  AuthenticationWidgetConfig.swift
//  Tests
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class AuthenticationWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.title = AuthenticationWidgetConfig.default.title
        self.subtitle = AuthenticationWidgetConfig.default.subtitle
        self.emailField = AuthenticationWidgetConfig.default.emailField
        self.passwordField = AuthenticationWidgetConfig.default.passwordField
        self.loginButton = AuthenticationWidgetConfig.default.loginButton
        self.signupButton = AuthenticationWidgetConfig.default.signupButton
    }

    public init(
        title: LabelConfig = AuthenticationWidgetConfig.default.title,
        subtitle: LabelConfig = AuthenticationWidgetConfig.default.subtitle,
        emailField: TextInputConfig = AuthenticationWidgetConfig.default
            .emailField,
        passwordField: TextInputConfig = AuthenticationWidgetConfig.default
            .passwordField,
        loginButton: TextButtonConfig = AuthenticationWidgetConfig.default
            .loginButton,
        signupButton: TextButtonConfig = AuthenticationWidgetConfig.default
            .signupButton
    ) {
        self.title = title
        self.subtitle = subtitle
        self.emailField = emailField
        self.passwordField = passwordField
        self.loginButton = loginButton
        self.signupButton = signupButton
    }

    // MARK: - Public

    public static let `default` = AuthenticationWidgetConfig(
        title: LabelConfig(fontStyle: .title),
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
            preferValidationErrorsToHelperMessage: true
        ),
        loginButton: TextButtonConfig(
            style: .primary, size: .large, isMaxWidth: true
        ),
        signupButton: TextButtonConfig(
            style: .primary, size: .small, isMaxWidth: false
        )
    )

    public let title: LabelConfig
    public let subtitle: LabelConfig

    public let emailField: TextInputConfig
    public let passwordField: TextInputConfig

    public let loginButton: TextButtonConfig
    public let signupButton: TextButtonConfig
}
