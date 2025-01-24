//
//  ParraContainerRenderer.swift
//  Parra
//
//  Created by Mick MacCallum on 3/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public class ParraContainerRenderer {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration
    ) {
        self.configuration = configuration
    }

    // MARK: - Public

    public func renderContainer<C: ParraContainer>(
        params: C.ContentObserver.InitialParams,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil,
        navigationPath: Binding<NavigationPath>
    ) -> C {
        let contentObserver = C.ContentObserver(
            initialParams: params
        )

        return renderContainer(
            contentObserver: contentObserver,
            config: config,
            contentTransformer: contentTransformer,
            navigationPath: navigationPath
        )
    }

    public func renderContainer<C: ParraContainer>(
        contentObserver: C.ContentObserver,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil,
        navigationPath: Binding<NavigationPath>
    ) -> C {
        contentTransformer?(contentObserver)

        return C(
            config: config,
            contentObserver: contentObserver,
            navigationPath: navigationPath
        )
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
}
