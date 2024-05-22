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
        params: Params
    ) {
        self.params = params
    }

    // MARK: - Public

    public struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            availableAuthMethods: [AuthenticationMethod],
            selectAuthMethod: @escaping (AuthenticationMethod) -> Void
        ) {
            self.availableAuthMethods = availableAuthMethods
            self.selectAuthMethod = selectAuthMethod
        }

        // MARK: - Public

        public let availableAuthMethods: [AuthenticationMethod]
        public let selectAuthMethod: (AuthenticationMethod) -> Void
    }

    public var body: some View {
        VStack {
            continueButton
        }
    }

    // MARK: - Internal

    var continueButtonTitle: String {
        let methods = params.availableAuthMethods
        let hasEmail = methods.contains(.password)
        let hasSms = methods.contains(.passwordless(.sms))

        if hasEmail, hasSms {
            return "Continue with Email or Phone"
        } else if hasEmail {
            return "Continue with Email"
        } else if hasSms {
            return "Continue with Phone"
        } else {
            return "Continue"
        }
    }

    @ViewBuilder var continueButton: some View {
        componentFactory.buildContainedButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .medium,
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

    // MARK: - Private

    private let params: Params

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
}
