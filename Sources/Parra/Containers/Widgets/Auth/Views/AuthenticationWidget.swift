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
                    HStack(spacing: 0) {
                        withContent(content: content.icon) { content in
                            ImageComponent(
                                content: content,
                                attributes: ImageAttributes(
                                    frame: .fixed(
                                        FixedFrameAttributes(
                                            width: 60,
                                            height: 60
                                        )
                                    )
                                )
                            )
                        }

                        componentFactory.buildLabel(
                            config: config.title,
                            content: content.title,
                            suppliedBuilder: localBuilderConfig.title,
                            localAttributes: LabelAttributes(
                                padding: .padding(
                                    leading: content.icon == nil ? 0 : 6
                                )
                            )
                        )
                    }
                    .padding(
                        .padding(
                            bottom: content.subtitle == nil ? 20 : 0
                        )
                    )

                    withContent(content: content.subtitle) { content in
                        componentFactory.buildLabel(
                            config: config.subtitle,
                            content: content,
                            suppliedBuilder: localBuilderConfig.subtitle
                        )
                    }
                }

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
        .onAppear {
            // When the view appears/reappears trigger a re-validation so that
            // any changes in field values are reflected in the UI.
            contentObserver.validateEmailFields()
        }
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
            VStack(spacing: 0) {
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
                    contentObserver.loginTapped()
                }

                componentFactory.buildTextButton(
                    variant: .contained,
                    config: config.loginButton,
                    content: content.loginButton
                ) {
                    contentObserver.loginTapped()
                }

                if let error = contentObserver.error {
                    componentFactory.buildLabel(
                        config: config.loginErrorLabel,
                        content: LabelContent(text: error),
                        localAttributes: .defaultFormCallout(
                            in: themeObserver.theme,
                            with: config.loginErrorLabel,
                            erroring: true
                        ).withUpdates(
                            updates: LabelAttributes(
                                padding: .padding(top: 4)
                            )
                        )
                    )
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

    @State private var password: String = ""

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
