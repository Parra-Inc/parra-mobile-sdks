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
            loginButton: TextButtonContent
        ) {
            self.title = title
            self.subtitle = subtitle
            self.emailField = emailField
            self.passwordField = passwordField
            self.loginButton = loginButton
        }

        // MARK: - Internal

        let title: LabelContent
        let subtitle: LabelContent?
        let emailField: TextInputContent
        let passwordField: TextInputContent
        let loginButton: TextButtonContent
    }
}
