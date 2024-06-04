//
//  ParraAuthDefaultLandingScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Temp until server updates!!!
public enum ParraIdentityType {
    case email
    case phone
}

public struct ParraAuthDefaultLandingScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.params = params
    }

    // MARK: - Public

    public struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            availableAuthMethods: [ParraAuthenticationMethod],
            selectAuthMethod: @escaping (ParraAuthenticationMethod) -> Void
        ) {
            self.availableAuthMethods = availableAuthMethods
            self.selectAuthMethod = selectAuthMethod
        }

        // MARK: - Public

        public let availableAuthMethods: [ParraAuthenticationMethod]
        public let selectAuthMethod: (ParraAuthenticationMethod) -> Void
    }

    public var body: some View {
        VStack(alignment: .leading) {
            titleLabel

            subtitleLabel

            continueButton
        }
        .frame(maxWidth: .infinity)
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    private let params: Params

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState

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
                .password
            )
        }
    }
}
