//
//  SubmissionOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 6/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

struct SubmissionOptions: View {
    // MARK: - Lifecycle

    init(
        params: ParraAuthDefaultIdentityChallengeScreen.Params,
        shouldDisableSubmitWithPassword: Binding<Bool>,
        passwordChallengeResponse: Binding<ChallengeResponse?>,
        submitResponse: @escaping (_: ChallengeResponse) async throws -> Void
    ) {
        self.params = params
        self._shouldDisableSubmitWithPassword = shouldDisableSubmitWithPassword
        self._passwordChallengeResponse = passwordChallengeResponse
        self.submitResponse = submitResponse
        self.primaryActionName = params.userExists ? "Log in" : "Sign up"
    }

    // MARK: - Internal

    struct SubmissionOptionInfo: Identifiable {
        let content: TextButtonContent
        let onPress: () async -> Void

        var id: String {
            return content.text.text
        }
    }

    let params: ParraAuthDefaultIdentityChallengeScreen.Params
    @Binding var shouldDisableSubmitWithPassword: Bool
    @Binding var passwordChallengeResponse: ChallengeResponse?
    let submitResponse: (_ response: ChallengeResponse) async throws -> Void

    var body: some View {
        VStack {
            if let errorMessage {
                componentFactory.buildLabel(
                    content: LabelContent(text: errorMessage),
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: themeObserver.theme.palette.error
                                .toParraColor()
                        ),
                        padding: .lg
                    )
                )
            }

            buttons
        }
    }

    // MARK: - Private

    @State private var errorMessage: String?

    private let primaryActionName: String

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    @ViewBuilder private var buttons: some View {
        let buttonInfo = getActionButtonInfo()

        if buttonInfo.isEmpty {
            EmptyView()
        } else if buttonInfo.count == 1 {
            let info = buttonInfo[0]

            SubmissionButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                variant: .contained,
                content: info.content,
                onPress: info.onPress
            )
        } else if buttonInfo.count == 2 {
            let info1 = buttonInfo[0]
            let info2 = buttonInfo[1]

            SubmissionButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                variant: .contained,
                content: info1.content,
                onPress: info1.onPress
            )

            SubmissionButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .medium,
                    isMaxWidth: true
                ),
                variant: .plain,
                content: info2.content,
                onPress: info2.onPress
            )
        } else {
            // For cases with 3 (or more) options, render contained first,
            // outlined second, all others plain.

            let info1 = buttonInfo[0]
            let info2 = buttonInfo[1]

            SubmissionButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                variant: .contained,
                content: info1.content,
                onPress: info1.onPress
            )

            SubmissionButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .medium,
                    isMaxWidth: true
                ),
                variant: .outlined,
                content: info2.content,
                onPress: info2.onPress
            )

            ForEach(buttonInfo.dropFirst(2)) { info in
                SubmissionButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .medium,
                        isMaxWidth: true
                    ),
                    variant: .plain,
                    content: info.content,
                    onPress: info.onPress
                )
            }
        }
    }

    private func getActionButtonInfo() -> [SubmissionOptionInfo] {
        var buttonInfo = [SubmissionOptionInfo]()

        if params.passwordCurrentlyAvailable {
            buttonInfo.append(
                SubmissionOptionInfo(
                    content: TextButtonContent(
                        text: "\(primaryActionName) with password"
                    ),
                    onPress: {
                        await attemptSubmission(for: .password) {
                            if let passwordChallengeResponse {
                                try await submitResponse(
                                    passwordChallengeResponse
                                )
                            }
                        }
                    }
                )
            )
        }

        if params.passwordlessChallengesCurrentlyAvailable {
            let passwordlessLoginTitle: String = if let challenge = params
                .firstCurrentlyAvailablePasswordlessChallenge
            {
                switch challenge.id {
                case .passwordlessEmail:
                    "\(primaryActionName) with email"
                case .passwordlessSms:
                    "\(primaryActionName) with SMS"
                default:
                    primaryActionName
                }
            } else {
                // shouldn't happen
                primaryActionName
            }

            let passwordlessType: ParraAuthenticationMethod
                .PasswordlessType = if params.identityType == .phoneNumber
            {
                .sms
            } else {
                .email
            }

            buttonInfo.append(
                SubmissionOptionInfo(
                    content: TextButtonContent(
                        text: passwordlessLoginTitle
                    ),
                    onPress: {
                        await attemptSubmission(
                            for: .passwordless(passwordlessType)
                        ) {
                            let challengeResponse: ChallengeResponse? =
                                switch params
                                    .identityType
                                {
                                case .email:
                                    .passwordlessEmail(params.identity)
                                case .phoneNumber:
                                    .passwordlessSms(params.identity)
                                default:
                                    // shound't happen
                                    nil
                                }

                            if let challengeResponse {
                                try await submitResponse(challengeResponse)
                            }
                        }
                    }
                )
            )
        }

        if !params.userExists, params.passkeySupported {
            buttonInfo.append(
                SubmissionOptionInfo(
                    content: TextButtonContent(
                        text: "Create a passkey"
                    ),
                    onPress: {
                        await attemptSubmission(for: .passkey) {
                            try await submitResponse(.passkey)
                        }
                    }
                )
            )
        }

        return buttonInfo
    }

    private func attemptSubmission(
        for authMethod: ParraAuthenticationMethod,
        _ fn: () async throws -> Void
    ) async {
        do {
            Task { @MainActor in
                withAnimation {
                    errorMessage = nil
                }
            }

            try await fn()
        } catch let error as ParraError {
            Task { @MainActor in
                let userFacingMessage = if let message = error.userMessage,
                                           message.contains("invalid")
                {
                    switch authMethod {
                    case .passwordless(let passwordlessType):
                        "Error sending \(passwordlessType.description) code"
                    case .password:
                        "The supplied password was incorrect"
                    case .sso(let ssoType):
                        "Error performing SSO login with \(ssoType.description)"
                    case .passkey:
                        "Error creating passkey"
                    }
                } else {
                    "An unexpected error occurred"
                }

                withAnimation {
                    errorMessage = userFacingMessage
                }
            }

            logger.error("Error submiting auth challenge", error)
        } catch {
            Task { @MainActor in
                withAnimation {
                    errorMessage = error.localizedDescription
                }
            }

            logger.error("Unknown error submiting auth challenge", error)
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            SubmissionOptions(
                params: ParraAuthDefaultIdentityChallengeScreen.Params(
                    identity: "mickm@hey.com",
                    identityType: .email,
                    userExists: false,
                    availableChallenges: [
                        .init(id: .password)
                    ],
                    supportedChallenges: [
                        .init(id: .password), .init(id: .passwordlessSms),
                        .init(id: .passkeys)
                    ],
                    legalInfo: .validStates()[0],
                    submit: { _ in },
                    forgotPassword: {}
                ),
                shouldDisableSubmitWithPassword: .constant(false),
                passwordChallengeResponse: .constant(nil),
                submitResponse: { _ in }
            )

            Spacer()

            SubmissionOptions(
                params: ParraAuthDefaultIdentityChallengeScreen.Params(
                    identity: "mickm@hey.com",
                    identityType: .email,
                    userExists: false,
                    availableChallenges: [
                        .init(id: .password), .init(id: .passkeys)
                    ],
                    supportedChallenges: [
                        .init(id: .password), .init(id: .passwordlessSms),
                        .init(id: .passkeys)
                    ],
                    legalInfo: .validStates()[0],
                    submit: { _ in },
                    forgotPassword: {}
                ),
                shouldDisableSubmitWithPassword: .constant(false),
                passwordChallengeResponse: .constant(nil),
                submitResponse: { _ in }
            )

            Spacer()

            SubmissionOptions(
                params: ParraAuthDefaultIdentityChallengeScreen.Params(
                    identity: "mickm@hey.com",
                    identityType: .email,
                    userExists: false,
                    availableChallenges: [
                        .init(id: .password), .init(id: .passkeys),
                        .init(id: .passwordlessSms)
                    ],
                    supportedChallenges: [
                        .init(id: .password), .init(id: .passwordlessSms),
                        .init(id: .passkeys)
                    ],
                    legalInfo: .validStates()[0],
                    submit: { _ in },
                    forgotPassword: {}
                ),
                shouldDisableSubmitWithPassword: .constant(false),
                passwordChallengeResponse: .constant(nil),
                submitResponse: { _ in }
            )

            Spacer()

            SubmissionOptions(
                params: ParraAuthDefaultIdentityChallengeScreen.Params(
                    identity: "mickm@hey.com",
                    identityType: .email,
                    userExists: false,
                    availableChallenges: [
                        .init(id: .passkeys), .init(id: .passwordlessSms)
                    ],
                    supportedChallenges: [
                        .init(id: .password), .init(id: .passwordlessSms),
                        .init(id: .passkeys)
                    ],
                    legalInfo: .validStates()[0],
                    submit: { _ in },
                    forgotPassword: {}
                ),
                shouldDisableSubmitWithPassword: .constant(false),
                passwordChallengeResponse: .constant(nil),
                submitResponse: { _ in }
            )
        }
    }
    .environmentObject(
        ParraAppInfo.validStates()[0]
    )
}
