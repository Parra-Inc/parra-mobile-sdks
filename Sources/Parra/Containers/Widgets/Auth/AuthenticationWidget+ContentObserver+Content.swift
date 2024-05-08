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
            forgotPasswordButton: TextButtonContent,
            signupButton: TextButtonContent
        ) {
            self.emailField = emailField
            self.passwordField = passwordField
            self.loginButton = loginButton
            self.forgotPasswordButton = forgotPasswordButton
            self.signupButton = signupButton
        }

        // MARK: - Internal

        var emailField: TextInputContent
        var passwordField: TextInputContent
        var loginButton: TextButtonContent
        var forgotPasswordButton: TextButtonContent
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
                        title: LabelContent(
                            text: emailPassword.emailTitle
                        ),
                        placeholder: LabelContent(
                            text: emailPassword.emailPlaceholder
                        )
                    ),
                    passwordField: TextInputContent(
                        title: LabelContent(
                            text: emailPassword.passwordTitle
                        ),
                        placeholder: LabelContent(
                            text: emailPassword.passwordPlaceholder
                        )
                    ),
                    loginButton: TextButtonContent(
                        text: LabelContent(
                            text: emailPassword.loginButtonTitle ?? "Log in"
                        ),
                        isDisabled: true
                    ),
                    forgotPasswordButton: TextButtonContent(
                        text: LabelContent(
                            text: "Forgot password?"
                        )
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
                    title: LabelContent(
                        text: content.emailPassword?.emailTitle
                    ),
                    placeholder: LabelContent(
                        text: content.emailPassword?.emailPlaceholder
                    )
                ),
                passwordField: TextInputContent(
                    title: LabelContent(
                        text: content.emailPassword?.passwordTitle
                    ),
                    placeholder: LabelContent(
                        text: content.emailPassword?.passwordPlaceholder
                    )
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
            icon: ParraImageContent?,
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

        let icon: ParraImageContent?
        let title: LabelContent
        let subtitle: LabelContent?
        var emailContent: EmailContent?
        var signupContent: SignupContent
    }
}
