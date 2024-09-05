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
struct ParraContainerPreview<ContainerType>: View
    where ContainerType: Container
{
    // MARK: - Lifecycle

    init(
        content: @escaping (
            _ parra: Parra,
            _ factory: ComponentFactory,
            _ config: ContainerType.Config
        ) -> any View,
        config: ContainerType.Config = .init(),
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.configuration = .init(theme: theme)
        self.config = config
        self.factory = ComponentFactory(
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

        self.parra = Parra(
            parraInternal: ParraInternal
                .createParraSwiftUIPreviewsInstance(
                    appState: ParraAppState.shared,
                    authenticationMethod: .preview,
                    configuration: configuration
                )
        )
    }

    // MARK: - Internal

    var body: some View {
        // It is tempting to store the content observer for the container in env
        // here but this will only work for previews. At runtime, the app
        // wrapper won't have provided this object since it is specific to the
        // individual containers.
        ParraOptionalAuthWindow {
            AnyView(content(parra, factory, config))
        }
        .environment(config)
        .environment(factory)
        .environment(\.parra, parra)
        .environment(\.parraAuthState, authStateManager.current)
    }

    // MARK: - Private

    @ViewBuilder private var content: (
        _ parra: Parra,
        _ factory: ComponentFactory,
        _ config: ContainerType.Config
    ) -> any View

    private let factory: ComponentFactory
    private let config: ContainerType.Config
    private let configuration: ParraConfiguration
    private let parra: Parra

    @State private var authStateManager: ParraAuthStateManager
}
