//
//  ParraAuthDefaultForgotPasswordScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 7/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultForgotPasswordScreen: ParraAuthScreen, Equatable {
    // MARK: - Lifecycle

    public init(
        params: Params,
        config: Config
    ) {
        self.params = params
        self.config = config
        self._state = State(
            wrappedValue: ForgotPasswordStateManager(
                params: params
            )
        )
    }

    // MARK: - Public

    public struct Config: ParraAuthScreenConfig {
        public static var `default`: Config = .init()
    }

    public var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        ScrollView {
            primaryContent
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .contentMargins(
            [.horizontal, .bottom],
            contentPadding,
            for: .scrollContent
        )
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
    }

    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return true
    }

    // MARK: - Private

    private let params: Params
    private let config: Config

    // Presence of this indicates that a code has been sent.

    @State private var state: ForgotPasswordStateManager

    @Environment(\.parra) private var parra

    @Environment(ParraComponentFactory.self) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    @ViewBuilder private var primaryContent: some View {
        VStack(spacing: 12) {
            switch state.screen {
            case .initial, .codeSending:
                ForgotPasswordInitialStateView(
                    params: params,
                    isSending: state.screen == .codeSending,
                    onSendCode: state.sendCode
                )
            case .codeSent:
                ForgotPasswordCodeSentStateView(
                    params: params,
                    onEnterCode: state.submitCode
                )
            case .codeEntered(let code):
                ForgotPasswordNewPasswordStateView(
                    params: params,
                    code: code,
                    onSubmit: state.submitNewPassword
                )
            case .complete:
                ForgotPasswordCompleteView(
                    onComplete: state.complete
                )
            }

            Spacer()
                .layoutPriority(1)
        }
    }
}

#Preview("Forgot password") {
    ParraViewPreview { _ in
        ParraAuthDefaultForgotPasswordScreen(
            params: .init(
                identity: "mickm@hey.com",
                codeLength: 6,
                sendConfirmationCode: {
                    try! await Task.sleep(ms: 1_000)

                    return .init(rateLimited: false)
                },
                updatePassword: { code, password in
                    try! await Task.sleep(ms: 1_000)

                    print("code: \(code), password: \(password)")
                },
                complete: {}
            ),
            config: .init()
        )
    }
}
