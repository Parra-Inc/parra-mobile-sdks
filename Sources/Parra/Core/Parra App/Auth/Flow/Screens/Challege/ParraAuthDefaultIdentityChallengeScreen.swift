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

        GeometryReader { geometry in
            ScrollView {
                challengeContent

                if !params.userExists, params.legalInfo.hasDouments {
                    Spacer()

                    LegalInfoView(
                        legalInfo: params.legalInfo,
                        theme: themeObserver.theme
                    )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
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
        }
        .onAppear {
            shouldDisableSubmitWithPassword = passwordChallengeResponse == nil
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // MARK: - Private

    private let params: Params
    private let config: Config

    @State private var passwordChallengeResponse: ChallengeResponse?
    @State private var shouldDisableSubmitWithPassword: Bool = true

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    @ViewBuilder private var challengeContent: some View {
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
                identity: params.identity,
                passwordChallengeAvailable: passwordChallengeAvailable,
                userExists: params.userExists,
                onUpdate: { challenge, isValid in
                    passwordChallengeResponse = .password(challenge)

                    shouldDisableSubmitWithPassword = !isValid
                },
                onSubmit: {
                    if let passwordChallengeResponse {
                        try await submitChallengeResponse(
                            passwordChallengeResponse
                        )
                    }
                },
                forgotPassword: {
                    Task {
                        await params.forgotPassword()
                    }
                }
            )

            SubmissionOptions(
                params: params,
                shouldDisableSubmitWithPassword: $shouldDisableSubmitWithPassword,
                passwordChallengeResponse: $passwordChallengeResponse,
                submitResponse: submitChallengeResponse
            )
        }
        .applyPadding(
            size: .md,
            from: themeObserver.theme
        )
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

    private var title: String {
        if params.userExists {
            return "Login"
        }

        return "Create an account"
    }

    private func submitChallengeResponse(
        _ response: ChallengeResponse
    ) async throws {
        UIApplication.resignFirstResponder()

        logger.debug("Submitting challenge response")

        try await params.submit(
            response
        )
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
