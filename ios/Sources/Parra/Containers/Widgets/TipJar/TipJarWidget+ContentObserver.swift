//
//  TipJarWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

private let logger = Logger()

// MARK: - TipJarWidget.ContentObserver

extension TipJarWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.initialParams = initialParams

            self.content = Content()

            switch initialParams.products {
            case .products(let products):
                self.state = .loaded(products)
            case .productIds(let ids):
                self.state = .loading(ids)

                loadProducts(with: ids)
            }
        }

        // MARK: - Internal

        enum LoadingState {
            case loading([String])
            case loaded([Product])
            case failed(Error)

            // MARK: - Internal

            var productIds: [String] {
                switch self {
                case .failed:
                    return []
                case .loading(let productIds):
                    return productIds
                case .loaded(let products):
                    return products.map(\.id)
                }
            }
        }

        var content: Content
        let initialParams: InitialParams

        private(set) var state: LoadingState

        var isLoading: Bool {
            switch state {
            case .loading:
                return true
            default:
                return false
            }
        }

        // MARK: - Private

        private func loadProducts(
            with productIds: [String]
        ) {
            Task { @MainActor in
                do {
                    let products = try await Product.products(
                        for: productIds
                    ).reorder(by: productIds)

                    withAnimation {
                        self.state = .loaded(products)
                    }
                } catch {
                    let ids = productIds.joined(separator: ", ")
                    logger.error("Error loading tip jar products", error, [
                        "productIds": "[\(ids)]"
                    ])

                    withAnimation {
                        self.state = .failed(error)
                    }
                }
            }
        }
    }
}
