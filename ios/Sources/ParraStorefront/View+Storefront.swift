//
//  View+Storefront.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

import Buy
import Parra
import SwiftUI

public extension View {
    /// Automatically fetches the feed with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraStorefront(
        isPresented: Binding<Bool>,
        config: ParraStorefrontConfig,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = StorefrontTransformParams()

        let transformer: ParraViewDataLoader<
            StorefrontTransformParams,
            StorefrontParams,
            StorefrontWidget
        >.Transformer = { _, _ in
            let client = Graph.Client(
                shopDomain: config.shopifyDomain,
                apiKey: config.shopifyApiKey,
                session: config.shopifySession,
                locale: config.shopifyLocale
            )

            client.cachePolicy = config.shopifyCachePolicy

            let shopifyService = ShopifyService(
                client: client
            )

            let response = try await shopifyService.performQuery(
                .productsQuery(
                    count: storefrontPaginatorLimit
                )
            )

            return StorefrontParams(
                productsResponse: ParraProductResponse(
                    products: response.products.edges
                        .map { ParraProduct(shopProduct: $0.node) },
                    productPageInfo: ParraProductResponse.PageInfo(
                        startCursor: response.products.pageInfo.startCursor,
                        endCursor: response.products.pageInfo.endCursor,
                        hasNextPage: response.products.pageInfo.hasNextPage
                    )
                )
            )
        }

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(transformParams, transformer)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .storefrontLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
