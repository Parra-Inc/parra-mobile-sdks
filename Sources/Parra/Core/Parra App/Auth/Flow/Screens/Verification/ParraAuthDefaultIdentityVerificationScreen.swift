//
//  ParraAuthDefaultIdentityVerificationScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 6/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultIdentityVerificationScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.params = params

        print(params)
    }

    // MARK: - Public

    public var body: some View {
        VStack {
            ChallengeVerificationView(
                passwordlessConfig: params.passwordlessConfig
            ) { challenge, _ in
                currentCode = challenge
            } onSubmit: { code, _ in
                currentCode = code

                triggerVerifyCode()
            }

            actions

            componentFactory.buildLabel(
                text: "We'll send a one time login code to the phone number you entered. SMS & data charges may apply.",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .footnote,
                        color: themeObserver.theme.palette.secondaryText
                            .toParraColor(),
                        alignment: .center
                    ),
                    padding: .md
                )
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .overlay(alignment: .bottom) {
            if !params.userExists {
                LegalInfoView(
                    legalInfo: params.legalInfo,
                    theme: themeObserver.theme
                )
            }
        }
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
        .navigationTitle("Confirm it's you")
        .onAppear {
//            continueButtonContent = continueButtonContent.withLoading(false)
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    private let params: Params

    // Presence of this indicates that a code has been sent.
    @State private var challengeResponse: ParraPasswordlessChallengeResponse?
    @State private var currentCode: String = ""

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @EnvironmentObject private var flowManager: AuthenticationFlowManager

    @ViewBuilder private var actions: some View {
        if let challengeResponse {
            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                text: "Continue"
            ) {
                triggerVerifyCode()
            }

            HStack {
                componentFactory.buildPlainButton(
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: .small,
                        isMaxWidth: false
                    ),
                    text: "Resend code"
                ) {
                    triggerCodeSend()
                }

                Text(
                    timerInterval: Date() ... challengeResponse.expiresAt,
                    pauseTime: challengeResponse.expiresAt,
                    countsDown: true,
                    showsHours: false
                )
            }
        } else {
            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                text: "Send code"
            ) {
                triggerCodeSend()
            }
        }
    }

    private func triggerCodeSend() {
        Task {
            do {
                let result = try await params.requestCodeResend()

                withAnimation {
                    challengeResponse = result
                }
            } catch {
                print("Error sending code: \(error)")
            }
        }
    }

    private func triggerVerifyCode() {
        Task {
            do {
                try await params.verifyCode(currentCode)
            } catch {
                print("Error verifying code: \(error)")
            }
        }
    }
}

#Preview("Verify - SMS") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityVerificationScreen(
            params: .init(
                userExists: false,
                passwordlessConfig: .init(
                    sms: .init(otpLength: 6)
                ),
                legalInfo: LegalInfo.validStates()[0],
                requestCodeResend: {
                    return .init(
                        strategy: .sms,
                        status: .pending,
                        expiresAt: Date(),
                        retryAt: nil
                    )
                },
                verifyCode: { _ in
                }
            )
        )
        .environmentObject(
            AuthenticationFlowManager(
                flowConfig: .default,
                navigationState: .init()
            )
        )
    }
}
