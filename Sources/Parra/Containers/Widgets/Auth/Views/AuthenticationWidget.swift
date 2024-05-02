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
        NavigationStack(path: $navigationState.navigationPath) {
            mainView
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Internal

    let localBuilderConfig: AuthenticationWidgetBuilderConfig
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
                    localBuilderConfig: localBuilderConfig,
                    componentFactory: componentFactory,
                    contentObserver: contentObserver
                )
                .edgesIgnoringSafeArea([.top])
                .environmentObject(navigationState)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @StateObject private var navigationState = NavigationState()
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
