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

    @State var challenge: String = ""

    let passwordChallengeAvailable: Bool
    let userExists: Bool
    let onUpdate: (_ challenge: String) -> Void
    let onSubmit: () -> Void

    var body: some View {
        VStack {
            componentFactory.buildTextInput(
                config: challengeFieldConfig,
                content: TextInputContent(
                    placeholder: "Password",
                    errorMessage: .init()
                ) { newText in
                    challenge = newText ?? ""
                },
                localAttributes: ParraAttributes.TextInput(
                    padding: .zero
                )
            )
            .onChange(of: challenge) { _, newValue in
                onUpdate(newValue)
            }
            .onSubmit(of: .text, onSubmit)

            if let passwordConfig = parraAppInfo.auth.database?.password,
               passwordChallengeAvailable, !userExists
            {
                // Password strength view only shows up for create account flow
                // that supports password challenges.
                PasswordStrengthView(
                    password: $challenge,
                    rules: passwordConfig.rules
                )
            }
        }
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
        ChallengeView(
            passwordChallengeAvailable: true,
            userExists: true
        ) { _ in
        } onSubmit: {}
    }
}
