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
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraStorefrontWidgetConfig,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = StorefrontTransformParams()

        let transformer: ParraViewDataLoader<
            StorefrontTransformParams,
            StorefrontParams,
            StorefrontWidget
        >.Transformer = { _, _ in
            // If there's a cached response, use it.
            let productsResponse: ParraProductResponse = if let cachedProductsResponse =
                ParraStorefront.cachedPreloadResponse
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
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .storefrontLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
