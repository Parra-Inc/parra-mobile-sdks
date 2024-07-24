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
        challengeResponse: Binding<ChallengeResponse?>,
        loadingAuthMethod: Binding<ParraAuthenticationMethod?>,
        submit: @escaping () -> Void
    ) {
        self.params = params
        self.primaryActionName = params.userExists ? "Log in" : "Sign up"
        self._shouldDisableSubmitWithPassword = shouldDisableSubmitWithPassword
        self._loadingAuthMethod = loadingAuthMethod
        self._challengeResponse = challengeResponse
        self.submit = submit
    }

    // MARK: - Internal

    let params: ParraAuthDefaultIdentityChallengeScreen.Params

    @Binding var shouldDisableSubmitWithPassword: Bool
    @Binding var challengeResponse: ChallengeResponse?

    let submit: () -> Void

    var body: some View {
        VStack {
            buttons
        }
        .onChange(
            of: challengeResponse,
            initial: true
        ) { _, newValue in
            if let newValue, case .password(let password, _) = newValue {
                passwordLoginButtonDisabled = password.isEmpty
            }
        }
    }

    // MARK: - Private

    @State private var passwordLoginButtonDisabled = true

    /// The auth method that should be rendered with a loading spinner.
    @Binding private var loadingAuthMethod: ParraAuthenticationMethod?

    private let primaryActionName: String

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    @ViewBuilder private var buttons: some View {
        let buttonInfo = getActionButtonInfo(
            with: TextButtonContent(
                text: "\(primaryActionName) with password",
                isDisabled: passwordLoginButtonDisabled || loadingAuthMethod ==
                    .password,
                isLoading: loadingAuthMethod == .password
            )
        )

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
            .id(info)
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
            .id(info1)

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
            .id(info2)
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
            .id(info1)

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
            .id(info2)

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
                .id(info)
            }
        }
    }

    private func getActionButtonInfo(
        with passwordLoginButtonContent: TextButtonContent
    ) -> [SubmissionOptionInfo] {
        var buttonInfo = [SubmissionOptionInfo]()

        if params.passwordCurrentlyAvailable {
            buttonInfo.append(
                SubmissionOptionInfo(
                    content: passwordLoginButtonContent,
                    onPress: {
                        attemptSubmission(
                            for: .password
                        )
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

            let authMethod: ParraAuthenticationMethod = .passwordless(
                passwordlessType
            )

            buttonInfo.append(
                SubmissionOptionInfo(
                    content: TextButtonContent(
                        text: passwordlessLoginTitle,
                        isLoading: loadingAuthMethod == authMethod
                    ),
                    onPress: {
                        attemptSubmission(
                            for: authMethod
                        )
                    }
                )
            )
        }

        if !params.userExists, params.passkeySupported {
            buttonInfo.append(
                SubmissionOptionInfo(
                    content: TextButtonContent(
                        text: "Create a passkey",
                        isLoading: loadingAuthMethod == .passkey
                    ),
                    onPress: {
                        attemptSubmission(for: .passkey)
                    }
                )
            )
        }

        return buttonInfo
    }

    private func attemptSubmission(
        for authMethod: ParraAuthenticationMethod
    ) {
        let nextChallengeResponse: ChallengeResponse? = switch authMethod {
        case .passwordless(let passwordlessType):
            switch passwordlessType {
            case .email:
                .passwordlessEmail(params.identity)
            case .sms:
                .passwordlessSms(params.identity)
            }
        case .password:
            // Special case. Will already be set before submission
            challengeResponse
        case .sso:
            nil
        case .passkey:
            .passkey
        }

        challengeResponse = nextChallengeResponse

        submit()
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
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                submit: {}
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
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                submit: {}
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
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                submit: {}
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
                challengeResponse: .constant(nil),
                loadingAuthMethod: .constant(nil),
                submit: {}
            )
        }
    }
    .environmentObject(
        ParraAppInfo.validStates()[0]
    )
}
