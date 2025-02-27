//
//  ParraAuthDefaultLandingScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

public struct ParraAuthDefaultLandingScreen: ParraAuthScreen, Equatable {
    // MARK: - Lifecycle

    public init(
        params: Params,
        config: Config
    ) {
        self.params = params
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        VStack(alignment: .center) {
            Spacer()

            if let logoView = config.logoView {
                AnyView(logoView)
            } else {
                defaultLogoView
            }

            if let titleView = config.titleView {
                AnyView(titleView)
            } else {
                defaultTitleView
            }

            Spacer()

            continueButton

            ssoButtons

            if let bottomView = config.bottomView {
                AnyView(bottomView)
            } else {
                defaultBottomView
            }
        }
        .frame(maxWidth: .infinity)
        .applyDefaultWidgetAttributes(
            using: parraTheme
        )
        .applyBackground(background)
    }

    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return true
    }

    // MARK: - Internal

    var background: any ShapeStyle {
        return config.background
            ?? parraTheme.palette.primaryBackground.toParraColor()
    }

    // MARK: - Private

    private let params: Params
    private let config: Config

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraAppInfo) private var parraAppInfo
    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var isSigningInWithApple: Bool = false

    private var continueButtonTitle: String {
        let methods = params.availableAuthMethods
        let hasEmail = methods.contains(.password)
        let hasSms = methods.contains(.passwordless(.sms))

        if hasEmail, hasSms {
            return "Continue with email or phone"
        } else if hasEmail {
            return "Continue with email"
        } else if hasSms {
            return "Continue with phone"
        } else {
            return "Continue"
        }
    }

    private var signInWithAppleContent: ParraTextButtonContent {
        ParraTextButtonContent(
            text: ParraLabelContent(
                text: "Sign in with Apple",
                icon: .symbol("apple.logo", .hierarchical)
            ),
            isLoading: isSigningInWithApple
        )
    }

    @ViewBuilder private var defaultLogoView: some View {
        if let logo = parraAppInfo.tenant.logo {
            componentFactory.buildAsyncImage(
                config: ParraAsyncImageConfig(
                    showBlurHash: false
                ),
                content: ParraAsyncImageContent(
                    logo,
                    preferredThumbnailSize: .lg
                ),
                localAttributes: ParraAttributes.AsyncImage(
                    size: CGSize(width: 200, height: 200),
                    padding: .zero
                )
            )
        }
    }

    @ViewBuilder private var defaultTitleView: some View {
        titleLabel

        subtitleLabel

        Spacer()
    }

    @ViewBuilder private var defaultBottomView: some View {
        EmptyView()
    }

    @ViewBuilder private var titleLabel: some View {
        let titleAttributes = ParraAttributes.Label(
            text: ParraAttributes.Text(
                font: .systemFont(ofSize: 50, weight: .heavy),
                alignment: .center
            ),
            padding: .md
        )

        componentFactory.buildLabel(
            content: ParraLabelContent(
                text: "Welcome to\n\(parraAppInfo.application.name)"
            ),
            localAttributes: titleAttributes
        )
        .minimumScaleFactor(0.5)
        .lineLimit(2)
    }

    @ViewBuilder private var subtitleLabel: some View {
        let subtitleAttributes = ParraAttributes.Label(
            text: .default(with: .subheadline),
            padding: .zero
        )

        componentFactory.buildLabel(
            content: ParraLabelContent(text: "Continue to sign up or log in."),
            localAttributes: subtitleAttributes
        )
    }

    private var loginButtonConfig: ParraTextButtonConfig {
        ParraTextButtonConfig(
            type: .primary,
            size: .large,
            isMaxWidth: true
        )
    }

    @ViewBuilder private var continueButton: some View {
        componentFactory.buildContainedButton(
            config: loginButtonConfig,
            content: ParraTextButtonContent(
                text: continueButtonTitle
            )
        ) {
            params.selectAuthMethod(
                .credentials
            )
        }
    }

    @ViewBuilder
    @MainActor private var ssoButtons: some View {
        if params.availableAuthMethods.contains(.sso(.apple)) {
            componentFactory.buildContainedButton(
                config: loginButtonConfig,
                content: signInWithAppleContent,
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        label: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                color: colorScheme == .dark ? .black : .white
                            ),
                            icon: ParraAttributes.Image(
                                tint: colorScheme == .dark ? .black : .white
                            ),
                            background: colorScheme == .dark ? .white : .black
                        )
                    )
                )
            ) {
                Task {
                    defer {
                        isSigningInWithApple = false
                    }

                    do {
                        isSigningInWithApple = true

                        try await params.signInWithApple()
                    } catch {
                        alertManager.showErrorToast(
                            userFacingMessage: "Error signing in with Apple",
                            underlyingError: error
                        )

                        Logger.error("Error signing in with Apple", error)
                    }
                }
            }
        }
    }
}

#Preview("Credential and passkey") {
    ParraViewPreview { _ in
        ParraAuthDefaultLandingScreen(
            params: ParraAuthDefaultLandingScreen.Params(
                availableAuthMethods: [
                    .password,
                    .passwordless(.sms),
                    .passkey
                ],
                selectAuthMethod: { _ in },
                attemptPasskeyLogin: {},
                signInWithApple: {}
            ),
            config: .default
        )
    }
}

#Preview("No auth methods") {
    ParraViewPreview { _ in
        ParraAuthDefaultLandingScreen(
            params: ParraAuthDefaultLandingScreen.Params(
                availableAuthMethods: [
                ],
                selectAuthMethod: { _ in },
                attemptPasskeyLogin: {},
                signInWithApple: {}
            ),
            config: .default
        )
    }
}

#Preview("Passkey") {
    ParraViewPreview { _ in
        ParraAuthDefaultLandingScreen(
            params: ParraAuthDefaultLandingScreen.Params(
                availableAuthMethods: [
                    .passkey
                ],
                selectAuthMethod: { _ in },
                attemptPasskeyLogin: {},
                signInWithApple: {}
            ),
            config: .default
        )
    }
}
