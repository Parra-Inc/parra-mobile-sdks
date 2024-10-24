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
        config: ParraStorefrontWidgetConfig,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = StorefrontTransformParams()

        let transformer: ParraViewDataLoader<
            StorefrontTransformParams,
            StorefrontParams,
            StorefrontWidget
        >.Transformer = { _, _ in
            var productsResponse: ParraProductResponse!

                // If there's a cached response, use it.
                = if let cachedProductsResponse = ParraStorefront.cachedPreloadResponse
            {
                cachedProductsResponse
            } else {
                try await ParraStorefront.performProductPreload()
            }

            return StorefrontParams(
                productsResponse: productsResponse
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
