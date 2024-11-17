//
//  ViewDataLoader+TipJar.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

struct TipJarParams: Equatable {
    let products: [Product]
}

struct TipJarTransformParams: Equatable {
    let productIds: [String]
}

extension ParraViewDataLoader {
    static func tipJarLoader(
        config: ParraTipJarConfig
    ) -> ParraViewDataLoader<TipJarTransformParams, TipJarParams, TipJarWidget> {
        return ParraViewDataLoader<
            TipJarTransformParams,
            TipJarParams,
            TipJarWidget
        >(
            renderer: { parra, params, _ in
                let container: TipJarWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: TipJarWidget.ContentObserver
                            .InitialParams(
                                products: .products(params.products),
                                config: config,
                                api: parra.parraInternal.api
                            ),
                        config: config,
                        contentTransformer: nil
                    )

                return container
            }
        )
    }
}
