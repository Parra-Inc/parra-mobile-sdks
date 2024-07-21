//
//  ChallengeView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChallengeView: View {
    // MARK: - Internal

    enum Field {
        case password
    }

    @State private var validatedRules: [(PasswordRule, Bool)] = []

    @FocusState private var focusState: Field?

    let identity: String
    let passwordChallengeAvailable: Bool
    let userExists: Bool
    let challengeResponse: Binding<ChallengeResponse?>
    /// The auth method that should be rendered with a loading spinner.
    @Binding var loadingAuthMethod: ParraAuthenticationMethod?
    @Binding var passwordState: PasswordStrengthView.ValidityState

    let submit: () -> Void
    let forgotPassword: () async throws -> Void

    var body: some View {
        let palette = themeManager.theme.palette

        VStack(spacing: 16) {
            componentFactory.buildTextInput(
                config: .default,
                content: TextInputContent(
                    defaultText: identity,
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

            VStack(alignment: .trailing, spacing: 8) {
                componentFactory.buildTextInput(
                    config: challengeFieldConfig,
                    content: TextInputContent(
                        placeholder: "Password",
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
                .onChange(of: passwordState) { _, newValue in
                    challengeResponse.wrappedValue = .password(
                        password: newValue.password,
                        isValid: newValue.isValid
                    )
                }
                .onSubmit(of: .text, submit)
                .focused($focusState, equals: .password)

                if userExists {
                    forgotPasswordButton
                }
            }

            // Password strength view only shows up for create account flow
            // that supports password challenges.
            if !userExists {
                PasswordStrengthView(
                    passwordState: $passwordState,
                    validatedRules: $validatedRules
                )
            }
        }
        .onAppear {
            focusState = .password

            validate(
                password: passwordState.password
            )
        }
    }

    private func validate(
        password: String
    ) {
        if userExists {
            // User is logging in. We just want to enable the login button if
            // there is anything in the field. We won't be showing them the
            // strength view to know what's wrong.
            passwordState = .init(
                password: password,
                isValid: !password.isEmpty
            )

            return
        }

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
    }

    // MARK: - Private

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    private var challengeFieldConfig: TextInputConfig {
        let authInfo = parraAppInfo.auth

        if passwordChallengeAvailable {
            let rules = authInfo.database?.password?.rules ?? []
            let rulesDescriptor = authInfo.database?.password?
                .iosPasswordRulesDescriptor
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
                textContentType: userExists ? .password : .newPassword,
                textInputAutocapitalization: .never,
                passwordRuleDescriptor: rulesDescriptor
            )
        }

        let otpLength = authInfo.passwordless?.sms?.otpLength ?? 6

        return TextInputConfig(
            validationRules: [
                .minLength(otpLength),
                .maxLength(otpLength)
            ],
            keyboardType: .numberPad,
            textContentType: .oneTimeCode,
            textInputAutocapitalization: .never
        )
    }

    private var forgotPasswordButton: some View {
        componentFactory
            .buildPlainButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .medium,
                    isMaxWidth: false
                ),
                text: "Forgot password?",
                localAttributes: ParraAttributes.PlainButton(
                    normal: ParraAttributes.PlainButton
                        .StatefulAttributes(
                            label: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    alignment: .center
                                ),
                                padding: .zero
                            )
                        )
                ),
                onPress: {
                    Task {
                        do {
                            try await forgotPassword()
                        } catch let error as ParraError {
                            if case .rateLimited = error {
                                Logger.error(
                                    "Rate limited on forgot password",
                                    error
                                )
                            } else {
                                Logger.error(
                                    "Error sending password reset code",
                                    error
                                )
                            }
                        } catch {
                            Logger.error(
                                "Error sending password reset code",
                                error
                            )
                        }
                    }
                }
            )
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack(spacing: 30) {
            ChallengeView(
                identity: "mickm@hey.com",
                passwordChallengeAvailable: true,
                userExists: true,
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                passwordState: .constant(.init(password: "", isValid: false)),
                submit: {},
                forgotPassword: {}
            )

            ChallengeView(
                identity: "mickm@hey.com",
                passwordChallengeAvailable: true,
                userExists: false,
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                passwordState: .constant(.init(password: "", isValid: false)),
                submit: {},
                forgotPassword: {}
            )
        }
        .padding()
    }
    .environmentObject(ParraAppInfo.validStates()[0])
}
