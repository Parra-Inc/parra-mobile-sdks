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
            self.methods = initialParams.methods
            self.content = Content(
                title: LabelContent(
                    text: ParraInternal
                        .appBundleName() ?? "Welcome"
                ),
                subtitle: LabelContent(text: "subtitle"),
                emailField: TextInputContent(
                    placeholder: "Email address"
                ),
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

            content.emailField.textChanged = onEmailChanged
            content.passwordField.textChanged = onPasswordChanged
        }

        // MARK: - Internal

        let authWidgetConfig: AuthenticationWidgetConfig
        let authService: AuthService
        let alertManager: AlertManager
        let methods: [ParraAuthMethod]

        @Published var content: Content
        @Published var error: Error?
        @Published var loginButtonIsEnabled = false

        func loginTapped() {
            if content.loginButton.isLoading {
                return
            }

            let email = content.emailField.title?.text ?? ""
            let password = content.passwordField.title?.text ?? ""

            let emailError = TextValidator.validate(
                text: email,
                against: authWidgetConfig.emailField.validationRules
            )

            let passwordError = TextValidator.validate(
                text: password,
                against: authWidgetConfig.passwordField.validationRules
            )

//            guard emailError == nil && passwordError == nil else {
//                var validationErrors = [String : String]()
//
//                if let emailError {
//                    validationErrors["Email address"] = emailError
//                }
//
//                if let passwordError {
//                    validationErrors["Password"] = passwordError
//                }
//
//                alertManager.showErrorToast(
//                    userFacingMessage: "Login fields are invalid.",
//                    underlyingError: .validationFailed(
//                        failures: validationErrors
//                    )
//                )
//
//                return
//            }

            setLoading(true)

            Task {
                do {
                    try await authService.login(
                        username: "mickm@hey.com",
                        password: "efhG5wefy"
                    )
                } catch {
                    Logger.error(error)
                }

                setLoading(false)
            }
        }

        func signupTapped() {
            logger.info("Signup tapped")
        }

        func onEmailChanged(_ email: String?) {
            let emailValidationMessage = TextValidator.validate(
                text: email,
                against: authWidgetConfig.emailField.validationRules
            )

            content.emailField.errorMessage = emailValidationMessage
        }

        func onPasswordChanged(_ password: String?) {
            let passwordValidationMessage = TextValidator.validate(
                text: password,
                against: authWidgetConfig.passwordField.validationRules
            )

            content.passwordField.errorMessage = passwordValidationMessage
        }

        // MARK: - Private

        private func setLoading(_ isLoading: Bool) {
            Task { @MainActor in
                withAnimation {
                    content.loginButton.isLoading = isLoading
                }
            }
        }
    }
}
