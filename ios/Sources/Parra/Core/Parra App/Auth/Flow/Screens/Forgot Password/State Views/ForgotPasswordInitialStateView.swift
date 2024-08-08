//
//  ForgotPasswordInitialStateView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ForgotPasswordInitialStateView: View {
    // MARK: - Lifecycle

    init(
        params: ParraAuthDefaultForgotPasswordScreen.Params,
        isSending: Bool,
        onSendCode: @escaping () -> Void
    ) {
        self.params = params
        self.isSending = isSending
        self.onSendCode = onSendCode
    }

    // MARK: - Internal

    let params: ParraAuthDefaultForgotPasswordScreen.Params
    let isSending: Bool
    let onSendCode: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                text: "Confirm your identity",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title
                    ),
                    padding: .custom(.padding(top: 6))
                )
            )
            .layoutPriority(20)

            Text(
                "For security reasons, we'll send a \(params.codeLength)-digit verification code to **\(params.identity)**.\n\nIf you're unable to access this email address, please contact \(appInfo.application.name) support."
            )
            .font(.subheadline)
            .padding(.bottom, 12)
            .layoutPriority(20)

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: ParraTextButtonContent(
                    text: "Send code",
                    isDisabled: isSending,
                    isLoading: isSending
                ),
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: .zero
                    )
                ),
                onPress: {
                    onSendCode()
                }
            )
        }
        .layoutPriority(20)
    }

    // MARK: - Private

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var appInfo: ParraAppInfo
}

#Preview {
    ParraViewPreview { _ in
        ForgotPasswordInitialStateView(
            params: ParraAuthDefaultForgotPasswordScreen.Params(
                identity: "mickm@hey.com", codeLength: 6,
                sendConfirmationCode: {
                    return .init(rateLimited: false)
                }, updatePassword: { code, newPassword in
                    print(code, newPassword)
                },
                complete: {}
            ),
            isSending: false,
            onSendCode: {}
        )
    }
}
