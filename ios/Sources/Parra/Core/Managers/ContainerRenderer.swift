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

    func renderContainer<C: Container>(
        contentObserver: C.ContentObserver,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let theme = configuration.theme
        let componentFactory = ParraComponentFactory(
            attributes: configuration.globalComponentAttributes,
            theme: theme
        )

        contentTransformer?(contentObserver)

        return C(
            config: config,
            componentFactory: componentFactory,
            contentObserver: contentObserver
        )
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
}
