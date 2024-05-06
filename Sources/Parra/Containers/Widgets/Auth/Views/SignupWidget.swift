//
//  SignupWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO:
// 1. Forgot password?
// 2. Terms of Service

/// The login screen for the Parra app.
struct SignupWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraAuthConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        signupContent
            .applyDefaultWidgetAttributes(
                using: themeObserver.theme
            )
    }

    // MARK: - Internal

    enum Field: Int, Hashable, CaseIterable {
        case email
        case password
    }

    let componentFactory: ComponentFactory
    let config: ParraAuthConfig

    @StateObject var contentObserver: AuthenticationWidget.ContentObserver
    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var signupContent: some View {
        let content = contentObserver.content.signupContent

        VStack {
            componentFactory.buildTextInput(
                config: TextInputConfig(
                    textContentType: .emailAddress
                ),
                content: content.emailField
            )
            .padding(.top, 50)
            .padding(.bottom, 5)
            .submitLabel(.next)
            .focused($focusedField, equals: .email)
            .onSubmit {
                focusNextField($focusedField)
            }

            componentFactory.buildTextInput(
                config: TextInputConfig(
                    textContentType: .password
                ),
                content: content.passwordField
            )
            .padding(.bottom, 16)
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.signupTapped()
            }

            componentFactory.buildContainedButton(
                config: TextButtonConfig(
                    style: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: content.signupButton
            ) {
                contentObserver.signupTapped()
            }
        }
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?
}

#Preview {
    ParraContainerPreview<SignupWidget> { parra, factory, config in
        SignupWidget(
            config: config,
            componentFactory: factory,
            contentObserver: .init(
                initialParams: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager
                )
            )
        )
    }
}
