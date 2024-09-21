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
        validatedRules: Binding<[(ParraPasswordRule, Bool)]>
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
                        color: parraTheme.palette.primaryText
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
                                for: parraTheme
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
                from: parraTheme
            )
            .applyBackground(parraTheme.palette.secondaryBackground)
            .applyCornerRadii(
                size: .lg,
                from: parraTheme
            )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private

    @Binding private var state: ValidityState
    @Binding private var validatedRules: [(ParraPasswordRule, Bool)]
    @State private var passwordStrength: PasswordEntropyCalculator.Strength?

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder
    private func renderRule(
        rule: ParraPasswordRule,
        valid: Bool
    ) -> some View {
        let color = valid
            ? parraTheme.palette.success
            : parraTheme.palette.error

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
                    ParraPasswordConfig.validStates()[0].rules.elements
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
                    ParraPasswordConfig.validStates()[0].rules.elements
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
                    ParraPasswordConfig.validStates()[0].rules.elements
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
                    ParraPasswordConfig.validStates()[0].rules.elements
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
