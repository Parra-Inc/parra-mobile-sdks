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
        params: C.ContentObserver.InitialParams,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let contentObserver = C.ContentObserver(
            initialParams: params
        )

        return renderContainer(
            contentObserver: contentObserver,
            config: config,
            contentTransformer: contentTransformer
        )
    }

    @MainActor
    func renderContainer<C: Container>(
        contentObserver: C.ContentObserver,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let theme = configuration.theme
        let componentFactory = ComponentFactory(
            attributes: configuration.globalComponentAttributes,
            theme: theme
        )

        contentTransformer?(contentObserver)

        let style = C.Style.default(
            with: theme
        )

        return C(
            config: config,
            style: style,
            componentFactory: componentFactory,
            contentObserver: contentObserver
        )
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
}
