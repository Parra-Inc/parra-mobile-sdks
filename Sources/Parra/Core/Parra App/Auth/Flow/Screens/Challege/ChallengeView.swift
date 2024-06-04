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

    @State var passwordState: PasswordStrengthView.ValidityState = .init(
        password: "",
        isValid: false
    )

    @State private var validatedRules: [(PasswordRule, Bool)] = []

    let passwordChallengeAvailable: Bool
    let userExists: Bool
    let onUpdate: (_ challenge: String, _ isValid: Bool) -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
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
            .onSubmit(of: .text, onSubmit)

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
            validate(
                password: passwordState.password
            )
        }
    }

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
                passwordChallengeAvailable: true,
                userExists: true
            ) { _, _ in
            } onSubmit: {}

            ChallengeView(
                passwordChallengeAvailable: true,
                userExists: false
            ) { _, _ in
            } onSubmit: {}
        }
        .padding()
    }
    .environmentObject(ParraAppInfo.validStates()[0])
}
