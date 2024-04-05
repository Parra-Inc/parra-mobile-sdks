//
//  ContainerRenderer.swift
//  Parra
//
//  Created by Mick MacCallum on 3/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class ContainerRenderer {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration
    ) {
        self.configuration = configuration
    }

    // MARK: - Internal

    @MainActor
    func renderContainer<C: Container>(
        with localBuilder: C.BuilderConfig,
        params: C.ContentObserver.InitialParams,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let contentObserver = C.ContentObserver(
            initialParams: params
        )

        return renderContainer(
            with: localBuilder,
            contentObserver: contentObserver,
            config: config,
            contentTransformer: contentTransformer
        )
    }

    @MainActor
    func renderContainer<C: Container>(
        with localBuilder: C.BuilderConfig,
        contentObserver: C.ContentObserver,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let theme = configuration.theme
        let globalComponentAttributes = configuration.globalComponentAttributes

        let componentFactory = ComponentFactory(
            global: globalComponentAttributes,
            theme: theme
        )

        contentTransformer?(contentObserver)

        let style = C.Style.default(
            with: theme
        )

        return C(
            config: config,
            style: style,
            localBuilderConfig: localBuilder,
            componentFactory: componentFactory,
            contentObserver: contentObserver
        )
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
}
