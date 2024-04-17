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
        config: AuthenticationWidgetConfig,
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

        VStack(spacing: 12) {
            Spacer()

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

            componentFactory.buildTextInput(
                config: config.emailField,
                content: content.emailField
            )

            componentFactory.buildTextInput(
                config: config.passwordField,
                content: content.passwordField
            )

            componentFactory.buildTextButton(
                variant: .contained,
                config: config.loginButton,
                content: content.loginButton
            ) {
                contentObserver.loginTapped()
            }

            componentFactory.buildTextButton(
                variant: .plain,
                config: config.signupButton,
                content: content.signupButton
            ) {
                contentObserver.loginTapped()
            }

            Spacer()
        }
        .safeAreaPadding()
    }

    // MARK: - Internal

    let localBuilderConfig: AuthenticationWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: AuthenticationWidgetConfig
    let style: AuthenticationWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    // MARK: - Private

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
                    error: nil,
                    authService: parra.parraInternal.authService
                )
            )
        )
    }
}
