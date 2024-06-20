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

        self.parra = Parra(
            parraInternal: ParraInternal
                .createParraSwiftUIPreviewsInstance(
                    appState: appState,
                    authenticationMethod: .preview,
                    configuration: configuration
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
        //        .environmentObject(ParraAppInfo) // TODO: Need this?
        .environmentObject(factory)
    }

    // MARK: - Private

    @ViewBuilder private var content: (_ factory: ComponentFactory) -> Content

    private let factory: ComponentFactory
    private let configuration: ParraConfiguration
    private let parra: Parra

    @StateObject private var parraAuthState: ParraAuthState
}
