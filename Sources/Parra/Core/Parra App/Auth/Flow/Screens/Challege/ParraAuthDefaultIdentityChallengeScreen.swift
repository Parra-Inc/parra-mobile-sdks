//
//  ParraAuthDefaultIdentityChallengeScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// 1. Signing up or logging in?
// 2. Identity type?
// 3. Is in code entry mode?

public struct ParraAuthDefaultIdentityChallengeScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.primaryActionName = params.userExists ? "Log in" : "Sign Up"
        self.continueButtonContent = TextButtonContent(
            text: primaryActionName,
            isDisabled: true
        )
        self.params = params
    }

    // MARK: - Public

    public var body: some View {
        challengeContent
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
            .navigationTitle(primaryActionName)
            .onAppear {
                continueButtonContent = continueButtonContent.withLoading(false)
            }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    private let primaryActionName: String

    private let params: Params

    @State private var challengeResponse: ChallengeResponse?
    @State private var continueButtonContent: TextButtonContent

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @EnvironmentObject private var flowManager: AuthenticationFlowManager

    private var challengeContent: some View {
        VStack(alignment: .center, spacing: 16) {
            componentFactory.buildLabel(
                content: LabelContent(text: title),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .largeTitle),
                    padding: .md,
                    frame: .flexible(
                        .init(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    )
                )
            )

            ChallengeView(
                passwordChallengeAvailable: passwordChallengeAvailable,
                userExists: params.userExists,
                onUpdate: { challenge, isValid in
                    challengeResponse = .password(challenge)

                    continueButtonContent = continueButtonContent.withDisabled(
                        !isValid
                    )
                },
                onSubmit: {
                    if let challengeResponse {
                        submitChallengeResponse(challengeResponse)
                    }
                }
            )

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    size: .large,
                    isMaxWidth: true
                ),
                content: continueButtonContent,
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: .zero
                    )
                )
            ) {
                if let challengeResponse {
                    submitChallengeResponse(challengeResponse)
                }
            }

            if passwordlessChallengesAvailable,
               ![.uknownIdentity, .username].contains(params.identityType)
            {
                let passwordlessLoginTitle: String =
                    if passwordChallengeAvailable {
                        "\(primaryActionName) without password"
                    } else if let challenge =
                        firstAvailablePasswordlessChallenge
                    {
                        // If there isn't a password challenge available, we
                        //
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

                componentFactory.buildPlainButton(
                    config: .default,
                    content: TextButtonContent(
                        text: passwordlessLoginTitle
                    ),
                    localAttributes: ParraAttributes.PlainButton(
                        normal: ParraAttributes.PlainButton.StatefulAttributes(
                            padding: .zero
                        )
                    )
                ) {
                    let challengeResponse: ChallengeResponse? = switch params
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
                        submitChallengeResponse(challengeResponse)
                    }
                }
            }
        }
        .applyPadding(
            size: .md,
            from: themeObserver.theme
        )
    }

    private var firstAvailablePasswordlessChallenge: ParraAuthChallenge? {
        return params.availableChallenges.first { challenge in
            return challenge.id == .passwordlessEmail || challenge
                .id == .passwordlessSms
        }
    }

    private var passwordChallengeAvailable: Bool {
        let challenges = if params.userExists {
            params.availableChallenges
        } else {
            params.supportedChallenges
        }

        return challenges.contains { challenge in
            return challenge.id == .password
        }
    }

    private var passwordlessChallengesAvailable: Bool {
        let challenges = if params.userExists {
            params.availableChallenges
        } else {
            params.supportedChallenges
        }

        return challenges.contains { challenge in
            return challenge.id == .passwordlessEmail || challenge
                .id == .passwordlessSms
        }
    }

    private var title: String {
        if params.userExists {
            if passwordChallengeAvailable {
                return "Your password"
            }

            return ""
        }

        return ""
    }

    private func submitChallengeResponse(
        _ response: ChallengeResponse
    ) {
        continueButtonContent = continueButtonContent.withLoading(true)

        Task {
            do {
                try await params.submit(
                    response
                )

            } catch {
                print(error)
            }

            Task { @MainActor in
                continueButtonContent = continueButtonContent.withLoading(false)
            }
        }
    }
}

#Preview("Email - Sign Up") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityChallengeScreen(
            params: .init(
                identity: "mickm@hey.com",
                identityType: .email,
                userExists: false,
                availableChallenges: [
                    .init(id: .password),
                    .init(id: .passwordlessEmail)
                ],
                supportedChallenges: [
                    .init(id: .password),
                    .init(id: .passwordlessEmail)
                ],
                legalInfo: LegalInfo.validStates()[0],
                submit: { _ in }
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

#Preview("Email - Log In") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityChallengeScreen(
            params: .init(
                identity: "mickm@hey.com",
                identityType: .email,
                userExists: true,
                availableChallenges: [
                    .init(id: .password)
                ],
                supportedChallenges: [
                    .init(id: .password)
                ],
                legalInfo: LegalInfo.validStates()[0],
                submit: { _ in }
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

#Preview("Phone - Sign Up") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityChallengeScreen(
            params: .init(
                identity: "2392335730",
                identityType: .phoneNumber,
                userExists: false,
                availableChallenges: [
                    .init(id: .passwordlessSms)
                ],
                supportedChallenges: [
                    .init(id: .passwordlessSms)
                ],
                legalInfo: LegalInfo.validStates()[0],
                submit: { _ in }
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

#Preview("Phone - Log In") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityChallengeScreen(
            params: .init(
                identity: "2392335730",
                identityType: .phoneNumber,
                userExists: true,
                availableChallenges: [
                    .init(id: .passwordlessSms)
                ],
                supportedChallenges: [
                    .init(id: .passwordlessSms)
                ],
                legalInfo: LegalInfo.validStates()[0],
                submit: { _ in }
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
