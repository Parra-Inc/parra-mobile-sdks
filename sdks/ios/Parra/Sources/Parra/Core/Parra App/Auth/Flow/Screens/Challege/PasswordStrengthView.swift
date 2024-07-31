//
//  PasswordStrengthView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PasswordStrengthView: View {
    // MARK: - Lifecycle

    init(
        passwordState: Binding<ValidityState>,
        validatedRules: Binding<[(PasswordRule, Bool)]>
    ) {
        self._state = passwordState
        self._validatedRules = validatedRules
    }

    // MARK: - Internal

    struct ValidityState: Equatable {
        let password: String
        let isValid: Bool
    }

    @ViewBuilder var header: some View {
        HStack {
            componentFactory.buildLabel(
                text: "Your password must include",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .caption,
                        color: themeManager.theme.palette.primaryText
                            .toParraColor()
                    )
                )
            )

            Spacer()

            if let passwordStrength {
                componentFactory.buildLabel(
                    text: passwordStrength.description,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .caption2,
                            color: passwordStrength.color(
                                for: themeManager.theme
                            )
                        )
                    )
                )
            }
        }
    }

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 6) {
                header
                    .padding(.bottom, 8)

                ForEach(
                    validatedRules,
                    id: \.0.regularExpression
                ) { rule, valid in
                    renderRule(
                        rule: rule,
                        valid: valid
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .applyPadding(
                size: .xl,
                from: themeManager.theme
            )
            .applyBackground(themeManager.theme.palette.secondaryBackground)
            .applyCornerRadii(
                size: .lg,
                from: themeManager.theme
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private

    @Binding private var state: ValidityState
    @Binding private var validatedRules: [(PasswordRule, Bool)]
    @State private var passwordStrength: PasswordEntropyCalculator.Strength?

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory

    @ViewBuilder
    private func renderRule(
        rule: PasswordRule,
        valid: Bool
    ) -> some View {
        let color = valid
            ? themeManager.theme.palette.success
            : themeManager.theme.palette.error

        let symbol = valid
            ? "checkmark.circle.fill"
            : "xmark.circle.fill"

        Label {
            componentFactory.buildLabel(
                text: rule.errorMessage,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .caption,
                        color: color.toParraColor()
                    )
                )
            )
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .padding(.trailing, 8)
        }
        .contentTransition(.symbolEffect(.automatic))
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            PasswordStrengthView(
                passwordState: .constant(.init(password: "", isValid: false)),
                validatedRules: .constant(
                    PasswordConfig.validStates()[0].rules
                        .map { (
                            $0,
                            false
                        ) }
                )
            )

            PasswordStrengthView(
                passwordState: .constant(.init(
                    password: "short",
                    isValid: false
                )),
                validatedRules: .constant(
                    PasswordConfig.validStates()[0].rules
                        .map { (
                            $0,
                            false
                        ) }
                )
            )

            PasswordStrengthView(
                passwordState: .constant(.init(
                    password: "abcdefghijklm",
                    isValid: false
                )),
                validatedRules: .constant(
                    PasswordConfig.validStates()[0].rules
                        .map { (
                            $0,
                            false
                        ) }
                )
            )

            PasswordStrengthView(
                passwordState: .constant(.init(
                    password: "Gfo4FZ1-34Dy!",
                    isValid: false
                )),
                validatedRules: .constant(
                    PasswordConfig.validStates()[0].rules
                        .map { (
                            $0,
                            false
                        ) }
                )
            )
        }
        .padding()
    }
}
