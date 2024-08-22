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
        content: @escaping (_ factory: ComponentFactory) -> Content
    ) {
        self.content = content
        self.configuration = .init(themeOptions: theme)
        self.factory = ComponentFactory(
            attributes: ParraGlobalComponentAttributes.default,
            theme: theme
        )

        self._authStateManager = State(
            initialValue: ParraAuthStateManager.shared
        )

        let appState = ParraAppState(
            tenantId: ParraInternal.Demo.tenantId,
            applicationId: ParraInternal.Demo.applicationId
        )

        let parraInternal = ParraInternal
            .createParraSwiftUIPreviewsInstance(
                appState: appState,
                authenticationMethod: .preview,
                configuration: configuration
            )

        self.parra = Parra(parraInternal: parraInternal)

        self._alertManager = StateObject(
            wrappedValue: parraInternal.alertManager
        )

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
        .environmentObject(alertManager)
        .environmentObject(
            LaunchScreenStateManager(
                state: .complete(
                    .init(
                        appInfo: ParraAppInfo.validStates()[0]
                    )
                )
            )
        )
        .environmentObject(factory)
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ factory: ComponentFactory) -> Content

    private let factory: ComponentFactory
    private let configuration: ParraConfiguration
    private let parra: Parra

    @StateObject private var alertManager: AlertManager

    @State private var authStateManager: ParraAuthStateManager
    @State private var themeManager: ParraThemeManager = .shared
}
