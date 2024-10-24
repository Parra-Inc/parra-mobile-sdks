//
//  ParraViewDataLoader+Storefront.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

import Parra
import SwiftUI

private let logger = ParraLogger()

struct StorefrontParams: Equatable {
    let productsResponse: ParraProductResponse
}

struct StorefrontTransformParams: Equatable {}

extension ParraViewDataLoader {
    static func storefrontLoader(
        config: ParraStorefrontWidgetConfig,
        delegate: ParraStorefrontWidgetDelegate? = nil
    )
        -> ParraViewDataLoader<
            StorefrontTransformParams,
            StorefrontParams,
            StorefrontWidget
        >
    {
        return ParraViewDataLoader<
            StorefrontTransformParams,
            StorefrontParams,
            StorefrontWidget
        >(
            renderer: { _, params, _ in
                let container: StorefrontWidget = Parra.containerRenderer.renderContainer(
                    params: StorefrontWidget.ContentObserver.InitialParams(
                        config: config,
                        delegate: delegate,
                        productsResponse: params.productsResponse
                    ),
                    config: config,
                    contentTransformer: nil
                )

                return container
            }
        )
    }
}
