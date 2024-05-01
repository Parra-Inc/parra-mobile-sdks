//
//  AuthenticationWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthenticationWidget.ContentObserver {
    struct SignupContent {
        // MARK: - Lifecycle

        init(
            emailField: TextInputContent,
            passwordField: TextInputContent,
            signupButton: TextButtonContent
        ) {
            self.emailField = emailField
            self.passwordField = passwordField
            self.signupButton = signupButton
        }

        // MARK: - Internal

        var emailField: TextInputContent
        var passwordField: TextInputContent
        var signupButton: TextButtonContent
    }

    struct EmailContent {
        // MARK: - Lifecycle

        init(
            emailField: TextInputContent,
            passwordField: TextInputContent,
            loginButton: TextButtonContent,
            signupButton: TextButtonContent
        ) {
            self.emailField = emailField
            self.passwordField = passwordField
            self.loginButton = loginButton
            self.signupButton = signupButton
        }

        // MARK: - Internal

        var emailField: TextInputContent
        var passwordField: TextInputContent
        var loginButton: TextButtonContent
        var signupButton: TextButtonContent
    }

    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(content: ParraAuthContent) {
            let subtitle: LabelContent? = if let subtitle = content.subtitle {
                LabelContent(
                    text: subtitle
                )
            } else {
                nil
            }

            let emailContent: EmailContent? = if let emailPassword = content
                .emailPassword
            {
                EmailContent(
                    emailField: TextInputContent(
                        placeholder: emailPassword.emailPlaceholder
                    ),
                    passwordField: TextInputContent(
                        placeholder: emailPassword.passwordPlaceholder
                    ),
                    loginButton: TextButtonContent(
                        text: LabelContent(
                            text: emailPassword.loginButtonTitle ?? "Log in"
                        ),
                        isDisabled: true
                    ),
                    signupButton: TextButtonContent(
                        text: LabelContent(
                            text: emailPassword
                                .signupButtonTitle ??
                                "Don't have an account? Sign up"
                        )
                    )
                )
            } else {
                nil
            }

            let signupContent = SignupContent(
                emailField: TextInputContent(
                    placeholder: content.emailPassword?
                        .emailPlaceholder ?? "email address"
                ),
                passwordField: TextInputContent(
                    placeholder: content.emailPassword?
                        .passwordPlaceholder ?? "password"
                ),
                signupButton: TextButtonContent(
                    text: LabelContent(
                        text: "Sign up"
                    )
                )
            )

            self.init(
                icon: content.icon,
                title: LabelContent(
                    text: content.title
                ),
                subtitle: subtitle,
                emailContent: emailContent,
                signupContent: signupContent
            )
        }

        init(
            icon: ImageContent?,
            title: LabelContent,
            subtitle: LabelContent?,
            emailContent: EmailContent?,
            signupContent: SignupContent
        ) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.emailContent = emailContent
            self.signupContent = signupContent
        }

        // MARK: - Internal

        let icon: ImageContent?
        let title: LabelContent
        let subtitle: LabelContent?
        var emailContent: EmailContent?
        var signupContent: SignupContent
    }
}
