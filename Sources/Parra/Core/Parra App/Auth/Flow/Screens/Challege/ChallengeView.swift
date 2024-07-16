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

    @State var passwordState: PasswordStrengthView.ValidityState = .init(
        password: "",
        isValid: false
    )

    @State private var validatedRules: [(PasswordRule, Bool)] = []

    @FocusState private var focusState: Field?

    let identity: String
    let passwordChallengeAvailable: Bool
    let userExists: Bool
    let onUpdate: (_ challenge: String, _ isValid: Bool) -> Void
    let onSubmit: () async throws -> Void
    let forgotPassword: () async throws -> Void

    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            componentFactory.buildTextInput(
                config: .default,
                content: TextInputContent(
                    defaultText: identity,
                    placeholder: ""
                ),
                localAttributes: ParraAttributes.TextInput(
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
                    onUpdate(newValue.password, newValue.isValid)
                }
                .onSubmit(of: .text, onReceiveSubmit)
                .focused($focusState, equals: .password)

                if let errorMessage {
                    componentFactory.buildLabel(
                        content: LabelContent(text: errorMessage),
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                color: themeObserver.theme.palette.error
                                    .toParraColor()
                            ),
                            padding: .lg
                        )
                    )
                }

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

    private func onReceiveSubmit() {
        Task {
            do {
                try await onSubmit()

                Task { @MainActor in
                    withAnimation {
                        errorMessage = nil
                    }
                }
            } catch let error as ParraError {
                Task { @MainActor in
                    withAnimation {
                        errorMessage = error.userMessage
                    }
                }

                Logger.error("Failed to submit identity", error)
            } catch {
                Task { @MainActor in
                    withAnimation {
                        errorMessage = error.localizedDescription
                    }
                }

                Logger.error("Failed to submit identity. Unknown error", error)
            }
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
    @EnvironmentObject private var themeObserver: ParraThemeObserver
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
}

#Preview {
    ParraViewPreview { _ in
        VStack(spacing: 30) {
            ChallengeView(
                identity: "mickm@hey.com",
                passwordChallengeAvailable: true,
                userExists: true,
                onUpdate: { _, _ in },
                onSubmit: {},
                forgotPassword: {}
            )

            ChallengeView(
                identity: "mickm@hey.com",
                passwordChallengeAvailable: true,
                userExists: false,
                onUpdate: { _, _ in },
                onSubmit: {},
                forgotPassword: {}
            )
        }
        .padding()
    }
    .environmentObject(ParraAppInfo.validStates()[0])
}
