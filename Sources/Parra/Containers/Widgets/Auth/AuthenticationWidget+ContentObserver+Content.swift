//
//  AuthenticationWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthenticationWidget.ContentObserver {
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

            self.init(
                title: LabelContent(
                    text: content.title
                ),
                subtitle: subtitle,
                emailContent: emailContent
            )
        }

        init(
            title: LabelContent,
            subtitle: LabelContent?,
            emailContent: EmailContent?
        ) {
            self.title = title
            self.subtitle = subtitle
            self.emailContent = emailContent
        }

        // MARK: - Internal

        let title: LabelContent
        let subtitle: LabelContent?
        var emailContent: EmailContent?
    }
}
