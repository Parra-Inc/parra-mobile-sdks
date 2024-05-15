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
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
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

    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var mainView: some View {
        let content = contentObserver.content

        Spacer()

        VStack(spacing: 0) {
            VStack(spacing: 0) {
                withContent(content: content.icon) { content in
                    componentFactory.buildImage(
                        content: content,
                        localAttributes: ParraAttributes.Image(
                            size: CGSize(width: 60.0, height: 60.0)
                        )
                    )
                }

                componentFactory.buildLabel(
                    content: content.title,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            font: .largeTitle
                        ),
                        padding: .custom(
                            .padding(bottom: content.icon == nil ? 0 : 6)
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
                    content: content,
                    localAttributes: .default(with: .subheadline)
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
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
        .navigationDestination(for: String.self) { destination in
            if destination == "signup" {
                SignupWidget(
                    config: config,
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
            componentFactory: factory,
            contentObserver: AuthenticationWidget.ContentObserver(
                initialParams: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager,
                    legalInfo: AppInfo.validStates()[0].legal
                )
            )
        )
    }
}
