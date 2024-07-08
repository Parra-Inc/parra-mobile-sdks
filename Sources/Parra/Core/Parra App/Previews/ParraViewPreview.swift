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

        self._parraAuthState = StateObject(
            wrappedValue: ParraAuthState()
        )

        let appState = ParraAppState(
            tenantId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId
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

        self._themeObserver = StateObject(
            wrappedValue: ParraThemeObserver(
                theme: parraInternal.configuration.theme,
                notificationCenter: parraInternal.notificationCenter
            )
        )
    }

    // MARK: - Internal

    var body: some View {
        ParraOptionalAuthWindow { _ in
            content(factory)
        }
        .environment(\.parra, parra)
        .environmentObject(parraAuthState)
        .environmentObject(alertManager)
        .environmentObject(themeObserver)
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
    @StateObject private var parraAuthState: ParraAuthState
    @StateObject private var themeObserver: ParraThemeObserver
}
