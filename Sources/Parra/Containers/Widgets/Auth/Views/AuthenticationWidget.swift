//
//  AuthenticationWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// The login screen for the Parra app.
public struct AuthenticationWidget: Container {
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
        let content = contentObserver.content

        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    componentFactory.buildLabel(
                        config: config.title,
                        content: content.title,
                        suppliedBuilder: localBuilderConfig.title
                    )

                    withContent(content: content.subtitle) { content in
                        componentFactory.buildLabel(
                            config: config.subtitle,
                            content: content,
                            suppliedBuilder: localBuilderConfig.subtitle
                        )
                    }
                }

                Spacer()

                if usingEmail {
                    emailPasswordViews
                }
            }
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
    @StateObject var contentObserver: ContentObserver
    let config: ParraAuthConfig
    let style: AuthenticationWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var usingEmail: Bool {
        contentObserver.content.emailContent != nil
    }

    @ViewBuilder var emailPasswordViews: some View {
        if let content = contentObserver.content.emailContent {
            VStack {
                componentFactory.buildTextInput(
                    config: config.emailField,
                    content: content.emailField
                )
                .submitLabel(.next)
                .focused($focusedField, equals: .email)
                .onSubmit {
                    focusNextField($focusedField)
                }

                componentFactory.buildTextInput(
                    config: config.passwordField,
                    content: content.passwordField
                )
                .submitLabel(.return)
                .focused($focusedField, equals: .password)
                .onSubmit {
                    contentObserver.loginTapped()
                }

                componentFactory.buildTextButton(
                    variant: .contained,
                    config: config.loginButton,
                    content: content.loginButton
                ) {
                    contentObserver.loginTapped()
                }
            }

            Spacer()

            componentFactory.buildTextButton(
                variant: .plain,
                config: config.signupButton,
                content: content.signupButton
            ) {
                contentObserver.signupTapped()
            }
        }
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?

    @Environment(\.parra) private var parra
}

#Preview {
    ParraContainerPreview<AuthenticationWidget> { parra, factory, _, builderConfig in
        AuthenticationWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
            componentFactory: factory,
            contentObserver: AuthenticationWidget.ContentObserver(
                initialParams: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager,
                    initialError: nil
                )
            )
        )
    }
}
