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
            self.authWidgetConfig = initialParams.config
            self.authService = initialParams.authService
            self.alertManager = initialParams.alertManager
            self.content = Content(content: initialParams.content)

            content.emailContent?.emailField.textChanged = onEmailChanged
            content.emailContent?.passwordField.textChanged = onPasswordChanged
        }

        // MARK: - Internal

        let authWidgetConfig: ParraAuthConfig
        let authService: AuthService
        let alertManager: AlertManager

        @Published var content: Content
        @Published var error: String?

        func loginTapped() {
            guard let emailContent = content.emailContent else {
                return
            }

            if emailContent.loginButton.isLoading {
                return
            }

            validateEmailFields(alwaysShowErrors: true)

            // double optionals from dictionary access
            guard
                let e = values[.email], let email = e,
                let p = values[.password], let password = p else
            {
                error = "Email and password are required."

                return
            }

            setLoading(true)

            Task {
                let authResult = await self.authService.login(
                    username: email,
                    password: password
                )

                setLoading(false)

                Task { @MainActor in
                    switch authResult {
                    case .authenticated(let parraUser):
                        logger.info("Login successful", [
                            "user_id": parraUser.info.user?.id ?? ""
                        ])
                    case .unauthenticated(let error):
                        logger.error("Login failed", error)

                        self
                            .error =
                            "Login failed. Ensure your email and password are correct."
                    }
                }
            }
        }

        func validateEmailFields(
            fields: [AuthenticationWidget.Field] = AuthenticationWidget.Field
                .allCases,
            alwaysShowErrors: Bool = false
        ) {
            var areAllValid = true

            for field in fields {
                let text = values[field] ?? nil

                // Only render error fields if text is non-nil or if the flag
                // to always show errors is set to true. We do this to avoid
                // showing error messages before the user has entered anything,
                // until they submit the form, then we want to show all errors.
                switch field {
                case .email:
                    let error = TextValidator.validate(
                        text: text,
                        against: authWidgetConfig.emailField.validationRules
                    )

                    areAllValid = areAllValid && error == nil

                    if text != nil || alwaysShowErrors {
                        content.emailContent?.emailField.errorMessage = error
                    }
                case .password:
                    let error = TextValidator.validate(
                        text: text,
                        against: authWidgetConfig.passwordField.validationRules
                    )

                    areAllValid = areAllValid && error == nil

                    if text != nil || alwaysShowErrors {
                        content.emailContent?.passwordField.errorMessage = error
                    }
                }
            }

            content.emailContent?.loginButton.isDisabled = !areAllValid
        }

        func signupTapped() {
            logger.info("Signup tapped")
        }

        func onEmailChanged(_ email: String?) {
            values[.email] = email

            validateEmailFields()
        }

        func onPasswordChanged(_ password: String?) {
            values[.password] = password

            validateEmailFields()
        }

        // MARK: - Private

        private var values: [AuthenticationWidget.Field: String?] = [:]

        private func setLoading(_ isLoading: Bool) {
            Task { @MainActor in
                withAnimation {
                    content.emailContent?.loginButton.isLoading = isLoading
                }
            }
        }
    }
}