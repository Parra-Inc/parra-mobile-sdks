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

    public var body: some View {
        VStack(alignment: .center) {
            Spacer()

            if let topView = config.topView {
                AnyView(topView)
            } else {
                defaultTopView
            }

            Spacer()

            continueButton

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

    // MARK: - Internal

    var background: any ShapeStyle {
        return config.background
            ?? parraTheme.palette.primaryBackground.toParraColor()
    }

    // MARK: - Private

    private let params: Params
    private let config: Config

    @EnvironmentObject private var componentFactory: ComponentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraAppInfo) private var parraAppInfo

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

        return "Welcome to\n\(name)"
    }

    @ViewBuilder private var defaultTopView: some View {
        if let logo = parraAppInfo.tenant.logo {
            componentFactory.buildAsyncImage(
                content: ParraAsyncImageContent(
                    url: logo.url
                ),
                localAttributes: ParraAttributes.AsyncImage(
                    size: CGSize(width: 200, height: 200),
                    padding: .zero
                )
            )
        }

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
            content: ParraLabelContent(text: title),
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

    @ViewBuilder private var continueButton: some View {
        componentFactory.buildContainedButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .large,
                isMaxWidth: true
            ),
            content: ParraTextButtonContent(
                text: continueButtonTitle
            )
        ) {
            params.selectAuthMethod(
                .credentials
            )
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
                attemptPasskeyLogin: {}
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
                attemptPasskeyLogin: {}
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
                attemptPasskeyLogin: {}
            ),
            config: .default
        )
    }
}
