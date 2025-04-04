//
//  ParraViewPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// To be used internally to provide Parra related context for individual views.
/// If you're building a top level scene, use ``ParraContainerPreview`` instead.
@MainActor
struct ParraViewPreview<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        theme: ParraTheme = .default,
        @ViewBuilder content: @escaping (_ factory: ParraComponentFactory) -> Content
    ) {
        self.content = content
        self.configuration = .init(theme: theme)
        self.factory = ParraComponentFactory(
            attributes: ParraGlobalComponentAttributes.default,
            theme: theme
        )

        self._authStateManager = State(
            initialValue: ParraAuthStateManager.shared
        )

        ParraAppState.shared = ParraAppState(
            tenantId: ParraInternal.Demo.tenantId,
            applicationId: ParraInternal.Demo.applicationId
        )

        let parraInternal = ParraInternal
            .createParraSwiftUIPreviewsInstance(
                appState: ParraAppState.shared,
                authenticationMethod: .preview,
                configuration: configuration
            )

        self.parra = Parra(parraInternal: parraInternal)

        ParraThemeManager.shared.current = parraInternal.configuration.theme
    }

    // MARK: - Internal

    var body: some View {
        ParraOptionalAuthWindow {
            content(factory)
        }
        .environment(\.parra, parra)
        .environment(\.parraAuthState, authStateManager.current)
        .environment(\.parraTheme, themeManager.current)
        .environment(\.parraPreferredAppearance, themeManager.preferredAppearanceBinding)
        .environment(\.parraAlertManager, alertManager)
        .environment(\.parraComponentFactory, factory)
        .environment(
            LaunchScreenStateManager(
                state: .complete(
                    .init(
                        appInfo: ParraAppInfo.validStates()[0]
                    )
                )
            )
        )
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ factory: ParraComponentFactory) -> Content

    private let factory: ParraComponentFactory
    private let configuration: ParraConfiguration
    private let parra: Parra

    @State private var alertManager: ParraAlertManager = .shared
    @State private var authStateManager: ParraAuthStateManager
    @State private var themeManager: ParraThemeManager = .shared
}
