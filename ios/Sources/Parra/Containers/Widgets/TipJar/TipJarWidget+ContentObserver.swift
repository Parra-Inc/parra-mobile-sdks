//
//  TipJarWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

extension TipJarWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.initialParams = initialParams

            self.content = Content(
                config: initialParams.config
            )

            switch initialParams.products {
            case .products(let products):
                self.isLoading = false
                self.products = products
            case .productIds(let ids):
                self.isLoading = true
                self.products = []

                loadProducts(with: ids)
            }
        }

        // MARK: - Internal

        var content: Content
        let initialParams: InitialParams

        var products: [Product]
        var isLoading: Bool

        // MARK: - Private

        private func loadProducts(
            with productIds: [String]
        ) {
            Task { @MainActor in
                do {
                    let products = try await Product.products(
                        for: productIds
                    ).reorder(by: productIds)
                } catch {}
            }
        }
    }
}
