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
        self.continueButtonContent = .init(
            text: "Continue"
        )

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
            .applyPadding(
                size: .md,
                from: themeObserver.theme
            )

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
            continueButtonContent = continueButtonContent.withLoading(false)
        }
        .onReceive(timer) { _ in
            processResponseChange(challengeResponse)
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    private let params: Params

    // Presence of this indicates that a code has been sent.
    @State private var challengeResponse: ParraPasswordlessChallengeResponse?
    @State private var currentCode: String = ""
    @State private var retryTimeRemaining: TimeInterval?
    @State private var continueButtonContent: TextButtonContent

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

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
                content: continueButtonContent
            ) {
                triggerVerifyCode()
            }

            HStack {
                let content: TextButtonContent = if let retryTimeRemaining,
                                                    challengeResponse
                                                    .retryAt != nil
                {
                    {
                        let duration = Duration(
                            secondsComponent: Int64(retryTimeRemaining),
                            attosecondsComponent: 0
                        ).formatted(.time(pattern: .minuteSecond))

                        return TextButtonContent(
                            text: "Resend code in \(duration)",
                            isDisabled: true
                        )
                    }()
                } else {
                    TextButtonContent(
                        text: "Resend code"
                    )
                }

                componentFactory.buildPlainButton(
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: .small,
                        isMaxWidth: false
                    ),
                    content: content
                ) {
                    triggerCodeSend()
                }
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

    private func processResponseChange(
        _ response: ParraPasswordlessChallengeResponse?
    ) {
        challengeResponse = response

        guard let response else {
            retryTimeRemaining = nil

            return
        }

        let now = Date.now

        withAnimation {
            if response.expiresAt < now {
                // If the challenge has expired, remove it.
                challengeResponse = nil
            }

            if let retryAt = response.retryAt {
                let diff = retryAt.timeIntervalSince(now)

                if diff <= 0 {
                    retryTimeRemaining = nil
                } else {
                    retryTimeRemaining = diff
                }
            } else {
                retryTimeRemaining = nil
            }
        }
    }

    private func triggerCodeSend() {
        Task {
            do {
                let result = try await params.requestCodeResend()

                print(result)

                Task { @MainActor in
                    processResponseChange(result)
                }
            } catch {
                print("Error sending code: \(error)")
            }
        }
    }

    private func triggerVerifyCode() {
        continueButtonContent = continueButtonContent.withLoading(true)

        Task {
            do {
                try await params.verifyCode(currentCode)
            } catch {
                print("Error verifying code: \(error)")
            }

            Task { @MainActor in
                continueButtonContent = continueButtonContent.withLoading(false)
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
