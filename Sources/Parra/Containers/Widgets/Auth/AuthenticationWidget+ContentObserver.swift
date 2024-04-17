//
//  AuthenticationWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

// MARK: - AuthenticationWidget.ContentObserver

extension AuthenticationWidget {
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.authService = initialParams.authService

            self.content = Content(
                title: LabelContent(
                    text: ParraInternal
                        .appBundleName() ?? "Welcome"
                ),
                subtitle: LabelContent(text: "subtitle"),
                emailField: TextInputContent(placeholder: "Email address"),
                passwordField: TextInputContent(placeholder: "Password"),
                loginButton: TextButtonContent(
                    text: LabelContent(text: "Log in")
                ),
                signupButton: TextButtonContent(
                    text: LabelContent(
                        text: "Don't have an account? Sign up"
                    )
                )
            )
        }

        // MARK: - Internal

        @Published var content: Content
        @Published var error: Error?
        @Published var loginButtonIsEnabled = false

        func loginTapped() {
            if content.loginButton.isLoading {
                return
            }

            withAnimation {
                content.loginButton.isLoading = true
            }

            Task {
                do {
                    try await authService.login(
                    )
                } catch {
                    Logger.error(error)
                }

                Task { @MainActor in
                    withAnimation {
                        content.loginButton.isLoading = false
                    }
                }
            }
        }

        // MARK: - Private

        private let authService: AuthService
    }
}
