//
//  ParraAuthDefaultLandingScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultLandingScreen: ParraAuthScreen {
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
        VStack(alignment: .leading) {
            titleLabel

            subtitleLabel

            continueButton

            if parraAppInfo.auth.supportsPasskeys {
                continueWithPasskeyButton
            }
        }
        .frame(maxWidth: .infinity)
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
        .task {
            do {
                try await params.attemptPasskeyLogin()
            } catch {
                Logger.error(
                    "Failed passkey auto login on landing screen",
                    error
                )
            }
        }
    }

    // MARK: - Internal

    @EnvironmentObject var parraAppInfo: ParraAppInfo

    // MARK: - Private

    private let params: Params
    private let config: Config

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @Environment(\.parra) private var parra

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

    private var title: String {
        guard let name = Parra.appBundleName() else {
            return "Welcome"
        }

        return "Welcome\nto \(name)"
    }

    @ViewBuilder private var titleLabel: some View {
        componentFactory.buildLabel(
            content: LabelContent(text: title),
            localAttributes: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: .systemFont(ofSize: 50, weight: .heavy),
                    alignment: .leading
                ),
                padding: .md
            )
        )
    }

    @ViewBuilder private var subtitleLabel: some View {
        componentFactory.buildLabel(
            content: LabelContent(text: "Sign up or log in to continue."),
            localAttributes: ParraAttributes.Label(
                text: .default(with: .subheadline),
                padding: .md
            )
        )
    }

    @ViewBuilder private var continueButton: some View {
        componentFactory.buildContainedButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .large,
                isMaxWidth: true
            ),
            content: TextButtonContent(
                text: continueButtonTitle
            )
        ) {
            params.selectAuthMethod(
                .credentials
            )
        }
    }

    @ViewBuilder private var continueWithPasskeyButton: some View {
        componentFactory.buildPlainButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .small,
                isMaxWidth: true
            ),
            content: TextButtonContent(
                text: "Continue with passkey"
            )
        ) {
            params.selectAuthMethod(
                .passkey
            )
        }
    }
}
