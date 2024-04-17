//
//  AuthenticationWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthenticationWidget.ContentObserver {
    struct Content: ContainerContent {
        // MARK: - Lifecycle

        init(
            title: LabelContent,
            subtitle: LabelContent?,
            emailField: TextInputContent,
            passwordField: TextInputContent,
            loginButton: TextButtonContent,
            signupButton: TextButtonContent
        ) {
            self.title = title
            self.subtitle = subtitle
            self.emailField = emailField
            self.passwordField = passwordField
            self.loginButton = loginButton
            self.signupButton = signupButton
        }

        // MARK: - Internal

        let title: LabelContent
        let subtitle: LabelContent?
        var emailField: TextInputContent
        var passwordField: TextInputContent
        var loginButton: TextButtonContent
        var signupButton: TextButtonContent
    }
}
