//
//  ParraContainerPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// To be used internally to provide Parra related context for an entire scene.
/// If you're building a component view, use ``ParraViewPreview`` instead.
@MainActor
public struct ParraContainerPreview<ContainerType>: View
    where ContainerType: ParraContainer
{
    // MARK: - Lifecycle

    public init(
        config: ContainerType.Config,
        theme: ParraTheme = .default,
        authState: ParraAuthState = .undetermined,
        content: @escaping (
            _ parra: Parra,
            _ factory: ParraComponentFactory,
            _ config: ContainerType.Config
        ) -> any View
    ) {
        self.content = content
        self.configuration = .init(theme: theme)
        self.config = config
        self.factory = ParraComponentFactory(
            attributes: ParraGlobalComponentAttributes.default,
            theme: theme
        )
        self._authStateManager = State(
            initialValue: ParraAuthStateManager(current: authState)
        )

        ParraAppState.shared = ParraAppState(
            tenantId: ParraInternal.Demo.tenantId,
            applicationId: ParraInternal.Demo.applicationId
        )

        self.parra = Parra(
            parraInternal: ParraInternal
                .createParraSwiftUIPreviewsInstance(
                    appState: ParraAppState.shared,
                    authenticationMethod: .preview,
                    configuration: configuration
                )
        )

        Parra.default.parraInternal = parra.parraInternal
    }

    // MARK: - Public

    public var body: some View {
        // It is tempting to store the content observer for the container in env
        // here but this will only work for previews. At runtime, the app
        // wrapper won't have provided this object since it is specific to the
        // individual containers.
        AnyView(content(parra, factory, config))
            .environment(config)
            .environment(\.parraComponentFactory, factory)
            .environment(\.parraAlertManager, alertManager)
            .environment(\.parra, parra)
            .environment(\.parraAuthState, authStateManager.current)
            .environment(
                \.parraComponentFactory,
                parra.parraInternal.globalComponentFactory
            )
            .environment(\.parraTheme, themeManager.current)
            .environment(\.parraUserProperties, userProperties)
    }

    // MARK: - Private

    @ViewBuilder private var content: (
        _ parra: Parra,
        _ factory: ParraComponentFactory,
        _ config: ContainerType.Config
    ) -> any View

    private let factory: ParraComponentFactory
    private let config: ContainerType.Config
    private let configuration: ParraConfiguration
    private let parra: Parra

    @State private var authStateManager: ParraAuthStateManager
    @State private var alertManager: ParraAlertManager = .shared
    @State private var themeManager: ParraThemeManager = .shared
    @State private var userProperties: ParraUserProperties = .shared
}
