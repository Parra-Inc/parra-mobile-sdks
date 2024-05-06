//
//  AuthenticationWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// The login screen for the Parra app.
struct AuthenticationWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraAuthConfig,
        style: AuthenticationWidgetStyle,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        NavigationStack(path: $navigationState.navigationPath) {
            mainView
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ParraAuthConfig
    let style: AuthenticationWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var mainView: some View {
        let content = contentObserver.content

        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    withContent(content: content.icon) { content in
                        ImageComponent(
                            content: content,
                            attributes: ParraAttributes.Image(
                                size: CGSize(width: 60.0, height: 60.0)
                            )
                        )
                    }

                    componentFactory.buildLabel(
                        fontStyle: .largeTitle,
                        content: content.title
                    )
                    .padding(.leading, content.icon == nil ? 0 : 6)
                }
                .padding(
                    .padding(
                        bottom: content.subtitle == nil ? 20 : 0
                    )
                )

                withContent(content: content.subtitle) { content in
                    componentFactory.buildLabel(
                        fontStyle: .subheadline,
                        content: content
                    )
                }

                if let emailContent = contentObserver.content.emailContent {
                    AuthenticationEmailPasswordView(
                        config: config,
                        content: emailContent,
                        contentObserver: contentObserver,
                        componentFactory: componentFactory
                    )
                    .environmentObject(navigationState)
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
        .navigationDestination(for: String.self) { destination in
            if destination == "signup" {
                SignupWidget(
                    config: config,
                    style: style,
                    componentFactory: componentFactory,
                    contentObserver: contentObserver
                )
                .ignoresSafeArea(.container, edges: .top)
                .environmentObject(navigationState)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @StateObject private var navigationState = NavigationState()
}

#Preview {
    ParraContainerPreview<AuthenticationWidget> { parra, factory, _ in
        AuthenticationWidget(
            config: .default,
            style: .default(with: .default),
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
