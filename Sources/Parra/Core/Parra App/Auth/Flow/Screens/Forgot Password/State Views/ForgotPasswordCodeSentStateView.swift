//
//  ForgotPasswordCodeSentStateView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ForgotPasswordCodeSentStateView: View {
    // MARK: - Lifecycle

    init(
        params: ParraAuthDefaultForgotPasswordScreen.Params,
        onEnterCode: @escaping (_ code: String) -> Void
    ) {
        self.params = params
        self.onEnterCode = onEnterCode
        self.continueButtonContent = TextButtonContent(
            text: "Continue",
            isDisabled: true,
            isLoading: false
        )
    }

    // MARK: - Internal

    let params: ParraAuthDefaultForgotPasswordScreen.Params
    let onEnterCode: (_ code: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            componentFactory.buildLabel(
                text: "Check your email!",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title
                    ),
                    padding: ParraPaddingSize.custom(
                        .padding(top: 6, bottom: 12)
                    )
                )
            )
            .layoutPriority(20)

            Text(
                "We've sent a \(params.codeLength)-digit code to **\(params.identity)**. Use this code to verify your identity before we change your password."
            )
            .font(.subheadline)
            .padding(.bottom, 12)

            componentFactory.buildLabel(
                text: "Enter the code:",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .callout
                    )
                )
            )
            .layoutPriority(20)

            ChallengeVerificationView(
                passwordlessConfig: .default,
                // ignore input before we've sent a code
                disabled: false,
                autoSubmit: false
            ) { challenge, _ in
                currentCode = challenge.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                continueButtonContent = TextButtonContent(
                    text: continueButtonContent.text,
                    isDisabled: currentCode.count < params.codeLength
                )
            } onSubmit: { _, _ in
                onEnterCode(currentCode)
            }
            .layoutPriority(15)
            .padding(.vertical, 8)

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
                onEnterCode(currentCode)
            }
        }
    }

    // MARK: - Private

    @State private var continueButtonContent: TextButtonContent
    @State private var currentCode: String = ""

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeManager: ParraThemeManager
}

#Preview {
    ParraViewPreview { _ in
        ForgotPasswordCodeSentStateView(
            params: ParraAuthDefaultForgotPasswordScreen.Params(
                identity: "mickm@hey.com", codeLength: 6,
                sendConfirmationCode: {
                    return .init(rateLimited: false)
                }, updatePassword: { code, newPassword in
                    print(code, newPassword)
                },
                complete: {}
            ),
            onEnterCode: { _ in }
        )
    }
}
