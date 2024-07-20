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
        .onChange(
            of: challengeResponse,
            initial: true
        ) { _, newValue in
            if case .password(_, let isValid) = newValue {
                shouldDisableSubmitWithPassword = !isValid
            } else if newValue == nil {
                shouldDisableSubmitWithPassword = true
            }
        }
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    @State var passwordState: PasswordStrengthView.ValidityState = .init(
        password: "",
        isValid: false
    )

    // MARK: - Private

    private let params: Params
    private let config: Config

    @State private var challengeResponse: ChallengeResponse?
    @State private var shouldDisableSubmitWithPassword: Bool = true
    @State private var errorMessage: String?

    /// The auth method that should be rendered with a loading spinner.
    @State private var loadingAuthMethod: ParraAuthenticationMethod?

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    @ViewBuilder private var challengeContent: some View {
        VStack(alignment: .center, spacing: 16) {
            componentFactory.buildLabel(
                content: LabelContent(text: title),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .title),
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
                challengeResponse: $challengeResponse,
                loadingAuthMethod: $loadingAuthMethod,
                passwordState: $passwordState,
                submit: submit,
                forgotPassword: {
                    // Force clearing the password before proceeding to
                    // forgot password. Prevents the Apple "save password"
                    // prompt from popping up when navigating away.
                    passwordState = .init(password: "", isValid: false)

                    try await params.forgotPassword()
                }
            )

            SubmissionOptions(
                params: params,
                shouldDisableSubmitWithPassword: $shouldDisableSubmitWithPassword,
                challengeResponse: $challengeResponse,
                loadingAuthMethod: $loadingAuthMethod,
                submit: submit
            )

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

    private func submit() {
        guard let challengeResponse,
              let authMethod = challengeResponse.authMethod else
        {
            logger.warn(
                "Unexpected submission of identity challenge without response set."
            )

            return
        }

        logger.debug("Submitting challenge response")

        UIApplication.resignFirstResponder()

        withAnimation {
            loadingAuthMethod = authMethod
        }

        Task {
            do {
                Task { @MainActor in
                    withAnimation {
                        errorMessage = nil
                    }
                }

                try await params.submit(
                    challengeResponse
                )

                Task { @MainActor in
                    withAnimation {
                        loadingAuthMethod = nil
                    }
                }
            } catch let error as ParraError {
                Task { @MainActor in
                    let userFacingMessage = if let message = error.userMessage,
                                               message.contains("invalid")
                    {
                        switch challengeResponse {
                        case .passkey:
                            "Error creating passkey"
                        case .password:
                            "The supplied password was incorrect"
                        case .passwordlessSms:
                            "Error sending login code via SMS"
                        case .passwordlessEmail:
                            "Error sending login code via email"
                        case .verificationSms:
                            "Error sending verification code via SMS"
                        case .verificationEmail:
                            "Error sending verification code via email"
                        }
                    } else {
                        "An unexpected error occurred"
                    }

                    withAnimation {
                        errorMessage = userFacingMessage
                        loadingAuthMethod = nil
                    }
                }

                logger.error("Error submiting auth challenge", error)
            } catch {
                Task { @MainActor in
                    withAnimation {
                        errorMessage = error.localizedDescription
                        loadingAuthMethod = nil
                    }
                }

                logger.error("Unknown error submiting auth challenge", error)
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
