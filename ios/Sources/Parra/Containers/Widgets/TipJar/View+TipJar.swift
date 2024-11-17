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
        isPresented: Binding<Bool>,
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
            with: .tipJarLoader(
                config: config
            ),
            onDismiss: nil
        )
    }
}
