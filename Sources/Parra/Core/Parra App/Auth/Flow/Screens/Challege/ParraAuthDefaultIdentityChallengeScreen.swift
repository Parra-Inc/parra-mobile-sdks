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
            text: primaryActionName
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

                flowManager.reset()
            }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    var isVerification: Bool {
        return params.availableChallenges.contains { challenge in
            return challenge.id.isVerification
        }
    }

    @ViewBuilder var challengeView: some View {
        if let passwordlessConfig = parraAppInfo.auth.passwordless,
           isVerification
        {
            ChallengeVerificationView(
                passwordlessConfig: passwordlessConfig
            ) { challenge, type in
                switch type {
                case .sms:
                    challengeResponse = .passwordlessSms(challenge)
                case .email:
                    challengeResponse = .passwordlessEmail(challenge)
                }
            } onSubmit: { code, type in
                switch type {
                case .sms:
                    submitChallengeResponse(
                        .passwordlessSms(code)
                    )
                case .email:
                    submitChallengeResponse(
                        .passwordlessEmail(code)
                    )
                }
            }
        } else {
            ChallengeView(
                passwordChallengeAvailable: passwordChallengeAvailable,
                userExists: params.userExists
            ) { challenge in
                challengeResponse = .password(challenge)
            }
        }
    }

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
        VStack {
            componentFactory.buildLabel(
                content: LabelContent(text: title),
                localAttributes: ParraAttributes.Label(
                    padding: .md
                )
            )

            challengeView
                .applyPadding(
                    size: .md,
                    from: themeObserver.theme
                )

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    size: .large,
                    isMaxWidth: true
                ),
                content: continueButtonContent,
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: .md
                    )
                )
            ) {
//                submitChallengeResponse(
//                    <#T##ChallengeResponse#>
//                )
            }

            if passwordlessChallengesAvailable {
                let passwordlessLoginTitle: String =
                    if passwordChallengeAvailable {
                        "\(primaryActionName) without password"
                    } else if let challenge =
                        firstAvailablePasswordlessChallenge
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
                        primaryActionName
                    }

                componentFactory.buildPlainButton(
                    config: .default,
                    content: TextButtonContent(
                        text: passwordlessLoginTitle
                    ),
                    localAttributes: ParraAttributes.PlainButton(
                        normal: .init(
                            padding: .md
                        )
                    )
                ) {}
            }
        }
    }

    private var firstAvailablePasswordlessChallenge: ParraAuthChallenge? {
        return params.availableChallenges.first { challenge in
            return challenge.id == .passwordlessEmail || challenge
                .id == .passwordlessSms
        }
    }

    private var passwordChallengeAvailable: Bool {
        return params.availableChallenges.contains { challenge in
            return challenge.id == .password
        }
    }

    private var passwordlessChallengesAvailable: Bool {
        return params.availableChallenges.contains { challenge in
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
                identityType: .phone,
                userExists: false,
                availableChallenges: [
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
                identityType: .phone,
                userExists: true,
                availableChallenges: [
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

#Preview("Phone - Verification") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityChallengeScreen(
            params: .init(
                identity: "2392335730",
                identityType: .phone,
                userExists: true,
                availableChallenges: [
                    .init(id: .verificationSms)
                ],
                legalInfo: LegalInfo.validStates()[0],
                submit: { _ in }
            )
        )
    }
}
