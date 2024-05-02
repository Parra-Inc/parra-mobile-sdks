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
// 2.

/// The login screen for the Parra app.
struct SignupWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraAuthConfig,
        style: AuthenticationWidgetStyle,
        localBuilderConfig: AuthenticationWidgetBuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.localBuilderConfig = localBuilderConfig
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        VStack {
            signupContent
                .padding(style.contentPadding)
                .applyCornerRadii(
                    size: style.cornerRadius,
                    from: themeObserver.theme
                )
        }
        .applyBackground(style.background)
        .padding(style.padding)
    }

    // MARK: - Internal

    enum Field: Int, Hashable, CaseIterable {
        case email
        case password
    }

    let localBuilderConfig: AuthenticationWidgetBuilderConfig
    let componentFactory: ComponentFactory
    let config: ParraAuthConfig
    let style: AuthenticationWidgetStyle

    @StateObject var contentObserver: AuthenticationWidget.ContentObserver
    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var signupContent: some View {
        let content = contentObserver.content.signupContent

        VStack {
            componentFactory.buildTextInput(
                config: config.emailField,
                content: content.emailField,
                localAttributes: TextInputAttributes(
                    padding: .padding(
                        top: 50,
                        bottom: 5
                    ),
                    textContentType: .emailAddress
                )
            )
            .submitLabel(.next)
            .focused($focusedField, equals: .email)
            .onSubmit {
                focusNextField($focusedField)
            }

            componentFactory.buildTextInput(
                config: config.passwordField,
                content: content.passwordField,
                localAttributes: TextInputAttributes(
                    padding: .padding(bottom: 16),
                    textContentType: .password
                )
            )
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.signupTapped()
            }

            componentFactory.buildTextButton(
                variant: .contained,
                config: config.signupConfirmButton,
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
    ParraContainerPreview<SignupWidget> { parra, factory, config, builderConfig in
        SignupWidget(
            config: config,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
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
