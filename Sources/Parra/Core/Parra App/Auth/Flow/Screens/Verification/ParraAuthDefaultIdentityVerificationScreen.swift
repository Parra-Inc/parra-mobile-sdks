//
//  ParraAuthDefaultIdentityVerificationScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 6/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let resendCodeTitle = "Resend code"

public struct ParraAuthDefaultIdentityVerificationScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.params = params
        self.continueButtonContent = .init(
            text: "Send code"
        )
    }

    // MARK: - Public

    public var body: some View {
        VStack {
            VStack(alignment: .leading) {
                componentFactory.buildLabel(
                    text: "Confirm your identity",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .title
                        )
                    )
                )

                componentFactory.buildLabel(
                    text: "We'll send a \(requiredLength)-digit code to \(params.identity) verify your identity.",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .subheadline
                        )
                    )
                )
            }

            ChallengeVerificationView(
                passwordlessConfig: params.passwordlessConfig,
                // ignore input before we've sent a code
                disabled: challengeResponse == nil
            ) { challenge, _ in
                if challengeResponse != nil {
                    currentCode = challenge.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                    continueButtonContent = TextButtonContent(
                        text: continueButtonContent.text,
                        isDisabled: currentCode.count < requiredLength
                    )
                }
            } onSubmit: { _, _ in }
                .applyPadding(
                    size: .md,
                    from: themeObserver.theme
                )

            actions

            componentFactory.buildLabel(
                text: disclaimerText,
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
            if !params.userExists, params.legalInfo.hasDouments {
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

    var disclaimerText: String {
        let prefix = switch params.passwordlessIdentityType {
        case .sms:
            "SMS & data charges may apply."
        case .email:
            "If you don't see the email, check your spam folder."
        }

        guard let challengeResponse else {
            return prefix
        }

        let expiresAt = challengeResponse.expiresAt
        let now = Date.now

        if expiresAt < now {
            return "Code expired. Tap '\(resendCodeTitle)' to try again."
        }

        return "\(prefix) Code expires in \(expiresAt.timeFromNowDisplay())"
    }

    var requiredLength: Int {
        return params.passwordlessConfig.sms?.otpLength ?? 6
    }

    // MARK: - Private

    private let params: Params

    // Presence of this indicates that a code has been sent.
    @State private var challengeResponse: ParraPasswordlessChallengeResponse?
    @State private var currentCode: String = ""
    @State private var retryTimeRemaining: TimeInterval?
    @State private var continueButtonContent: TextButtonContent
    @State private var errorMessage: String?

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
                            text: "\(resendCodeTitle) in \(duration)",
                            isDisabled: true
                        )
                    }()
                } else {
                    TextButtonContent(
                        text: resendCodeTitle
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
                content: continueButtonContent
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
            withAnimation {
                retryTimeRemaining = nil
            }

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
        continueButtonContent = continueButtonContent.withLoading(true)
        currentCode = ""

        Task {
            do {
                let result = try await params.requestCodeResend()

                Task { @MainActor in
                    processResponseChange(result)

                    if challengeResponse == nil {
                        continueButtonContent = TextButtonContent(
                            text: "Send code"
                        )
                    } else {
                        continueButtonContent = TextButtonContent(
                            text: "Continue",
                            isDisabled: true
                        )
                    }
                }
            } catch {
                print("Error sending code: \(error)")

                Task { @MainActor in
                    continueButtonContent = continueButtonContent
                        .withLoading(false)
                }
            }
        }
    }

    private func triggerVerifyCode() {
        continueButtonContent = continueButtonContent.withLoading(true)

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

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
                identity: "mickm@hey.com",
                passwordlessIdentityType: .email,
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
