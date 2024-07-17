//
//  ForgotPasswordNewPasswordStateView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ForgotPasswordNewPasswordStateView: View {
    // MARK: - Lifecycle

    init(
        params: ParraAuthDefaultForgotPasswordScreen.Params,
        code: String,
        onSubmit: @escaping (
            _ code: String,
            _ password: String
        ) async throws -> Void
    ) {
        self.params = params
        self.code = code
        self.onSubmit = onSubmit

        self._continueButtonContent = State(
            initialValue: TextButtonContent(
                text: "Save changes",
                isDisabled: true,
                isLoading: false
            )
        )
    }

    // MARK: - Internal

    enum Field {
        case password
        case passwordConfirmation
    }

    let params: ParraAuthDefaultForgotPasswordScreen.Params
    let code: String
    let onSubmit: (
        _ code: String,
        _ password: String
    ) async throws -> Void

    @State var passwordState: PasswordStrengthView.ValidityState = .init(
        password: "",
        isValid: false
    )

    var passwordFieldConfig: TextInputConfig {
        guard let passwordConfig = parraAppInfo.auth.database?.password else {
            return TextInputConfig()
        }

        let rules = passwordConfig.rules
        let rulesDescriptor = passwordConfig.iosPasswordRulesDescriptor
        let validationRules = rules.map { rule in
            TextValidatorRule.regex(
                rule.regularExpression,
                failureMessage: rule.errorMessage
            )
        }

        return TextInputConfig(
            validationRules: validationRules,
            resizeWhenHelperMessageIsVisible: true,
            isSecure: true,
            keyboardType: .default,
            textContentType: .newPassword,
            textInputAutocapitalization: .never,
            passwordRuleDescriptor: rulesDescriptor
        )
    }

    var body: some View {
        let palette = themeObserver.theme.palette

        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                text: "Update your password",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title
                    ),
                    padding: ParraPaddingSize.custom(
                        .padding(top: 6)
                    )
                )
            )
            .layoutPriority(20)

            componentFactory.buildTextInput(
                config: .default,
                content: TextInputContent(
                    defaultText: params.identity,
                    placeholder: ""
                ),
                localAttributes: .init(
                    text: ParraAttributes.Text(
                        color: palette.secondarySeparator.toParraColor()
                    ),
                    border: ParraAttributes.Border(
                        width: 1,
                        color: palette.secondarySeparator.toParraColor()
                    ),
                    padding: .zero
                )
            )
            .textContentType(.username)
            .disabled(true)
            .selectionDisabled()

            componentFactory.buildTextInput(
                config: passwordFieldConfig,
                content: TextInputContent(
                    title: "New password",
                    placeholder: nil,
                    errorMessage: nil
                ) { newText in
                    validate(
                        password: newText ?? ""
                    )
                },
                localAttributes: ParraAttributes.TextInput(
                    padding: .zero
                )
            )
            .onSubmit(of: .text, onReceiveSubmit)
            .focused($focusState, equals: .password)

            if showPasswordRules {
                PasswordStrengthView(
                    passwordState: $passwordState,
                    validatedRules: $validatedRules
                )
            }

            componentFactory.buildTextInput(
                config: passwordFieldConfig,
                content: TextInputContent(
                    title: "Confirm password",
                    placeholder: nil,
                    errorMessage: confirmationValidationErrorMessage
                ) { newText in
                    passwordConfirmation = newText ?? ""

                    updateSaveEnabled()
                },
                localAttributes: ParraAttributes.TextInput(
                    padding: .zero
                )
            )
            .onSubmit(of: .text, onReceiveSubmit)
            .focused($focusState, equals: .passwordConfirmation)

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: continueButtonContent,
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: ParraPaddingSize.custom(
                            .padding(top: 12, bottom: 12)
                        )
                    )
                )
            ) {
                onReceiveSubmit()
            }
        }
        .onChange(of: focusState) { _, newValue in
            withAnimation(.spring) {
                showPasswordRules = newValue == .password
            }
        }
        .onAppear {
            focusState = .password

            validate(
                password: passwordState.password
            )
        }
    }

    // MARK: - Private

    @State private var continueButtonContent: TextButtonContent
    @State private var passwordConfirmation: String = ""

    @State private var validatedRules: [(PasswordRule, Bool)] = []
    @FocusState private var focusState: Field?
    @State private var showPasswordRules = false
    @State private var errorMessage: String?
    @State private var confirmationValidationErrorMessage: String?

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    private func validate(
        password: String
    ) {
        guard let passwordConfig = parraAppInfo.auth.database?.password else {
            passwordState = .init(
                password: password,
                isValid: false
            )

            return
        }

        let rules = passwordConfig.rules

        if password.isEmpty {
            validatedRules = rules.map { rule in
                (rule, false)
            }
            passwordState = .init(
                password: password,
                isValid: false
            )

            return
        }

        var isValid = true

        validatedRules = rules.map { rule in
            let valid: Bool

            do {
                valid = try TextValidator.isValid(
                    text: password,
                    against: .regex(
                        rule.regularExpression,
                        failureMessage: rule.errorMessage
                    )
                )
            } catch {
                Logger.error("Error validating auth challenge", error)

                valid = false
            }

            if !valid {
                isValid = false
            }

            return (rule, valid)
        }

        passwordState = .init(
            password: password,
            isValid: isValid
        )

        updateSaveEnabled()
    }

    private func updateSaveEnabled() {
        continueButtonContent = continueButtonContent.withDisabled(
            !passwordState.isValid || passwordConfirmation.isEmpty
        )
    }

    private func onReceiveSubmit() {
        let passwordsMatch = passwordState.password == passwordConfirmation

        if !passwordsMatch {
            Logger.debug("Passwords do not match")

            confirmationValidationErrorMessage =
                "New passwords need to be the same"

            return
        } else {
            confirmationValidationErrorMessage = nil
        }

        withAnimation {
            UIApplication.resignFirstResponder()

            continueButtonContent = continueButtonContent.withLoading(true)
            errorMessage = nil
        }

        Logger.debug("Submitting new password")

        Task {
            do {
                try await onSubmit(code, passwordState.password)
            } catch {
                withAnimation {
                    continueButtonContent = continueButtonContent
                        .withLoading(false)
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview("Entry") {
    ParraViewPreview { _ in
        ForgotPasswordNewPasswordStateView(
            params: ParraAuthDefaultForgotPasswordScreen.Params(
                identity: "mickm@hey.com", codeLength: 6,
                sendConfirmationCode: {
                    return .init(rateLimited: false)
                }, updatePassword: { code, newPassword in
                    print(code, newPassword)
                },
                complete: {}
            ),
            code: "493854",
            onSubmit: { _, _ in }
        )
        .padding()
    }
}
