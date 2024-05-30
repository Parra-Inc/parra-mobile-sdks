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
        password: Binding<String>,
        rules: [PasswordRule]
    ) {
        self._password = password
        self.validatedRules = rules.map { ($0, false) }
    }

    // MARK: - Internal

    var header: some View {
        HStack {
            componentFactory.buildLabel(
                text: "Your password must include",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .caption,
                        color: themeObserver.theme.palette.primaryText
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
                                for: themeObserver.theme
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
                from: themeObserver.theme
            )
            .applyBackground(themeObserver.theme.palette.secondaryBackground)
            .applyCornerRadii(
                size: .lg,
                from: themeObserver.theme
            )
        }
        .frame(maxWidth: .infinity)
        .onChange(of: password) { _, _ in
            validate()
        }
    }

    // MARK: - Private

    @Binding private var password: String
    @State private var validatedRules: [(PasswordRule, Bool)]
    @State private var passwordStrength: PasswordEntropyCalculator.Strength?

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var componentFactory: ComponentFactory

    private func renderRule(
        rule: PasswordRule,
        valid: Bool
    ) -> some View {
        Label {
            componentFactory.buildLabel(
                text: rule.errorMessage,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .caption,
                        color: themeObserver.theme.palette.success
                            .toParraColor()
                    )
                )
            )
        } icon: {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(
                    themeObserver.theme.palette.success
                        .toParraColor()
                )
                .padding(.trailing, 8)
        }
    }

    private func validate() {
        password
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            PasswordStrengthView(
                password: .constant(""),
                rules: PasswordConfig.validStates()[0].rules
            )

            PasswordStrengthView(
                password: .constant("short"),
                rules: PasswordConfig.validStates()[0].rules
            )

            PasswordStrengthView(
                password: .constant("abcdefghijklm"),
                rules: PasswordConfig.validStates()[0].rules
            )

            PasswordStrengthView(
                password: .constant("Gfo4FZ1-34Dy!"),
                rules: PasswordConfig.validStates()[0].rules
            )
        }
        .padding()
    }
}
