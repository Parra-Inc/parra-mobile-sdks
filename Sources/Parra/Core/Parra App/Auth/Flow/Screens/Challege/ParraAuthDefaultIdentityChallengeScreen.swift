//
//  ParraAuthDefaultIdentityChallengeScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

public struct ParraAuthDefaultIdentityChallengeScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params,
        config: Config
    ) {
        self.params = params
        self.config = config
        self.primaryActionName = params.userExists ? "Log in" : "Sign Up"
        self.continueButtonContent = TextButtonContent(
            text: primaryActionName,
            isDisabled: true
        )
    }

    // MARK: - Public

    public struct Config: ParraAuthScreenConfig {
        public static var `default`: Config = .init()
    }

    public var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: themeObserver.theme
        )

        let contentPadding = themeObserver.theme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        ScrollView {
            challengeContent

            Spacer()

            if !params.userExists, params.legalInfo.hasDouments {
                Spacer()

                LegalInfoView(
                    legalInfo: params.legalInfo,
                    theme: themeObserver.theme
                )
            }
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
            using: themeObserver.theme
        )
        .onAppear {
            continueButtonContent = TextButtonContent(
                text: continueButtonContent.text,
                isDisabled: challengeResponse == nil
            )
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    private let primaryActionName: String

    private let params: Params
    private let config: Config

    @State private var challengeResponse: ChallengeResponse?
    @State private var continueButtonContent: TextButtonContent

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    private var challengeContent: some View {
        VStack(alignment: .center, spacing: 16) {
            componentFactory.buildLabel(
                content: LabelContent(text: title),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .largeTitle),
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

            if params.userExists, params.passwordAvailable {
                componentFactory
                    .buildPlainButton(
                        config: ParraTextButtonConfig(
                            type: .primary,
                            size: .medium,
                            isMaxWidth: false
                        ),
                        text: "Forgot password?",
                        localAttributes: ParraAttributes.PlainButton(
                            normal: ParraAttributes.PlainButton
                                .StatefulAttributes(
                                    label: ParraAttributes.Label(
                                        text: ParraAttributes.Text(
                                            alignment: .center
                                        )
                                    )
                                )
                        ),
                        onPress: {
                            Task {
                                await params.forgotPassword()
                            }
                        }
                    )
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
        if passwordChallengeAvailable {
            if params.userExists {
                return "Your password"
            }

            return "Create a password"
        }

        return ""
    }

    private func submitChallengeResponse(
        _ response: ChallengeResponse
    ) {
        continueButtonContent = continueButtonContent.withLoading(true)

        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        Task {
            do {
                logger.debug("Submitting challenge response")

                try await params.submit(
                    response
                )

            } catch {
                logger.error("Error submitting challenge response", error)
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
                submit: { _ in },
                forgotPassword: {}
            ),
            config: .init()
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
                submit: { _ in },
                forgotPassword: {}
            ),
            config: .init()
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
                submit: { _ in },
                forgotPassword: {}
            ),
            config: .init()
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
                submit: { _ in },
                forgotPassword: {}
            ),
            config: .init()
        )
    }
}
