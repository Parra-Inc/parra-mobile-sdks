//
//  View+TipJar.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

public extension View {
    /// Presents a sheet
    @MainActor
    func presentParraTipJar(
        with productIds: [String],
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraTipJarConfig = .default
    ) -> some View {
        let transformParams = TipJarTransformParams(
            productIds: productIds
        )

        let transformer: ParraViewDataLoader<
            TipJarTransformParams,
            TipJarParams,
            TipJarWidget
        >.Transformer = { _, _ in

            let products = try await Product.products(
                for: productIds
            ).reorder(by: productIds)

            if products.isEmpty {
                throw ParraError.message(
                    "Couldn't fetch products for provided tip jar product IDs."
                )
            }

            return TipJarParams(
                products: products
            )
        }

        return loadAndPresentSheet(
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .tipJarLoader(
                config: config
            ),
            onDismiss: nil
        )
    }
}
