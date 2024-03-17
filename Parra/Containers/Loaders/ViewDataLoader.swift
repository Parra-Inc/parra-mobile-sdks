//
//  ViewDataLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public struct ViewDataLoader<TransformParams, Data, ViewContent>
    where ViewContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    init(
        loader: @escaping (Parra, TransformParams) async throws -> Data,
        @ViewBuilder renderer: @MainActor @escaping (Parra, Data, Dismisser?)
            -> ViewContent
    ) {
        self.load = loader
        self.render = renderer
    }

    // MARK: - Internal

    enum LoadType: Equatable {
        // The input data requires transformation before use. Per container type
        // this should just be an ID string or a more complex type.
        case transform(TransformParams)

        // The data we want to display already exists at the call site so it can
        // be used directly.
        case raw(Data)
    }

    typealias Dismisser = @MainActor (SheetDismissType) -> Void

    @ViewBuilder let render: @MainActor (Parra, Data, Dismisser?) -> ViewContent

    let load: (Parra, TransformParams) async throws -> Data

    static func renderContainer<C: Container>(
        from parra: Parra,
        with localBuilder: C.BuilderConfig,
        params: C.ContentObserver.InitialParams,
        config: C.Config,
        contentTransformer: ((C.ContentObserver) -> Void)? = nil
    ) -> C {
        let theme = parra.configuration.theme

        let globalComponentAttributes = parra
            .configuration
            .globalComponentAttributes

        let componentFactory = ComponentFactory(
            global: globalComponentAttributes,
            theme: theme
        )

        let contentObserver = C.ContentObserver(
            initialParams: params
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
}
