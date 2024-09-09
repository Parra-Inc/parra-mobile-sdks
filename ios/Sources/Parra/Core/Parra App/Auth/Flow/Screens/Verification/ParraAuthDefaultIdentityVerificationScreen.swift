//
//  ParraAuthDefaultIdentityVerificationScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 6/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

private let resendCodeTitle = "Resend code"

@MainActor
public struct ParraAuthDefaultIdentityVerificationScreen: ParraAuthScreen, Equatable {
    // MARK: - Lifecycle

    public init(
        params: Params,
        config: Config
    ) {
        self.params = params
        self.config = config
        self.continueButtonContent = .init(
            text: "Send code"
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
        .scrollDismissesKeyboard(.immediately)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .overlay(alignment: .bottom) {
            if !params.userExists, params.legalInfo.hasDocuments {
                LegalInfoView(
                    legalInfo: params.legalInfo,
                    theme: parraTheme
                )
            }
        }
        .contentMargins(
            [.horizontal, .bottom],
            contentPadding,
            for: .scrollContent
        )
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .onAppear {
            continueButtonContent = continueButtonContent.withLoading(false)
        }
        .onReceive(timer) { _ in
            processResponseChange(challengeResponse)
        }
    }

    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return true
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
        let now = Date()

        if expiresAt < now {
            return "Code expired. Tap '\(resendCodeTitle)' to try again."
        }

        return "\(prefix) Code expires \(expiresAt.timeFromNowDisplay())"
    }

    var requiredLength: Int {
        return params.passwordlessConfig.sms?.otpLength ?? 6
    }

    // MARK: - Private

    private let params: Params
    private let config: Config

    // Presence of this indicates that a code has been sent.
    @State private var challengeResponse: ParraPasswordlessChallengeResponse?
    @State private var currentCode: String = ""
    @State private var retryTimeRemaining: TimeInterval?
    @State private var continueButtonContent: ParraTextButtonContent
    @State private var errorMessage: String?

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    @Environment(ComponentFactory.self) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    @ViewBuilder
    @MainActor private var primaryContent: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                componentFactory.buildLabel(
                    text: "Confirm your identity",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .title,
                            alignment: .leading
                        )
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                componentFactory.buildLabel(
                    text: "We'll send a \(requiredLength)-digit code to \(params.identity) verify your identity.",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .subheadline,
                            alignment: .leading
                        )
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            ChallengeVerificationView(
                passwordlessConfig: params.passwordlessConfig,
                // ignore input before we've sent a code
                disabled: challengeResponse == nil
            ) { challenge, _ in
                if challengeResponse != nil {
                    currentCode = challenge.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                    continueButtonContent = ParraTextButtonContent(
                        text: continueButtonContent.text,
                        isDisabled: currentCode.count < requiredLength
                    )
                }
            } onSubmit: { _, _ in }
                .layoutPriority(15)

            actions
                .layoutPriority(10)

            Spacer()
                .layoutPriority(1)

            if let errorMessage {
                componentFactory.buildLabel(
                    content: ParraLabelContent(text: errorMessage),
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: parraTheme.palette.error
                                .toParraColor()
                        ),
                        padding: .lg
                    )
                )
                .layoutPriority(10)
            } else {
                componentFactory.buildLabel(
                    text: disclaimerText,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .footnote,
                            color: parraTheme.palette.secondaryText
                                .toParraColor(),
                            alignment: .center
                        ),
                        padding: .md
                    )
                )
                .layoutPriority(10)
            }
        }
    }

    @ViewBuilder
    @MainActor private var actions: some View {
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
            .padding(.top, 8)

            HStack {
                let content: ParraTextButtonContent = if let retryTimeRemaining,
                                                         challengeResponse
                                                         .retryAt != nil
                {
                    {
                        let duration = Duration(
                            secondsComponent: Int64(retryTimeRemaining),
                            attosecondsComponent: 0
                        ).formatted(.time(pattern: .minuteSecond))

                        return ParraTextButtonContent(
                            text: "\(resendCodeTitle) in \(duration)",
                            isDisabled: true
                        )
                    }()
                } else {
                    ParraTextButtonContent(
                        text: resendCodeTitle
                    )
                }

                componentFactory.buildPlainButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .medium,
                        isMaxWidth: false
                    ),
                    content: content
                ) {
                    triggerCodeSend()
                }
                .frame(alignment: .center)
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
            .padding(.top, 8)
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

        let now = Date()

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
        errorMessage = nil

        Task {
            do {
                logger.debug("Sending one time code")

                let result = try await params.requestCodeResend()

                Task { @MainActor in
                    processResponseChange(result)

                    if challengeResponse == nil {
                        continueButtonContent = ParraTextButtonContent(
                            text: "Send code"
                        )
                    } else {
                        continueButtonContent = ParraTextButtonContent(
                            text: "Continue",
                            isDisabled: true
                        )
                    }
                }
            } catch {
                logger.error("Error sending code: \(error)")

                Task { @MainActor in
                    continueButtonContent = continueButtonContent
                        .withLoading(false)
                }
            }
        }
    }

    @MainActor
    private func triggerVerifyCode() {
        continueButtonContent = continueButtonContent.withLoading(true)

        UIApplication.dismissKeyboard()

        Task {
            do {
                logger.debug("Verifing one time code")

                try await params.verifyCode(currentCode)
            } catch {
                logger.error("Error verifying code: \(error)")

                withAnimation {
                    errorMessage = "Failed to verify SMS login code"
                    processResponseChange(nil)
                    continueButtonContent = ParraTextButtonContent(
                        text: "Send code"
                    )
                }
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
                legalInfo: ParraLegalInfo.validStates()[0],
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
            ),
            config: .init()
        )
    }
}
