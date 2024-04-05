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
            _ config: ContainerType.Config,
            _ builderConfig: ContainerType.BuilderConfig
        ) -> any View,
        config: ContainerType.Config = .init(),
        builderConfig: ContainerType.BuilderConfig = .init(),
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.configuration = .init(themeOptions: theme)
        self.config = config
        self.builderConfig = builderConfig
        self.factory = ComponentFactory(
            global: GlobalComponentAttributes(),
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        // It is tempting to store the content observer for the container in env
        // here but this will only work for previews. At runtime, the app
        // wrapper won't have provided this object since it is specific to the
        // individual containers.
        ParraAppView(
            target: .preview,
            configuration: configuration,
            viewContent: { parra in
                AnyView(content(parra, factory, config, builderConfig))
            }
        )
        .environment(builderConfig)
        .environment(config)
        .environmentObject(factory)
    }

    // MARK: - Private

    @ViewBuilder private var content: (
        _ parra: Parra,
        _ factory: ComponentFactory,
        _ config: ContainerType.Config,
        _ builderConfig: ContainerType.BuilderConfig
    ) -> any View

    private let factory: ComponentFactory
    private let config: ContainerType.Config
    private let builderConfig: ContainerType.BuilderConfig
    private let configuration: ParraConfiguration
}
