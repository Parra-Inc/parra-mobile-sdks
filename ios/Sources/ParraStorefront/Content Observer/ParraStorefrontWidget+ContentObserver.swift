//
//  ParraStorefrontWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Combine
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

// Shopify, smartly, introduces a Task object that conflicts with this.
// Typealias to take precedence.
typealias Task = _Concurrency.Task

private let logger = ParraLogger(category: "Parra Storefront Content Observer")

// MARK: - ParraStorefrontWidget.ContentObserver

extension ParraStorefrontWidget {
    @Observable
    @MainActor
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.config = initialParams.config

            self.content = Content(
                emptyStateView: .errorGeneric,
                errorStateView: .errorGeneric
            )

            let client = Graph.Client(
                shopDomain: config.shopifyDomain,
                apiKey: config.shopifyApiKey,
                session: config.shopifySession,
                locale: config.shopifyLocale
            )

            client.cachePolicy = config.shopifyCachePolicy
            self.client = client

            self.productPaginator = if let productsResponse = initialParams
                .productsResponse
            {
                .init(
                    context: "storefront",
                    data: .init(
                        items: productsResponse.products.elements,
                        placeholderItems: [],
                        pageSize: 25,
                        knownCount: productsResponse.products.elements.count
                    ),
                    pageFetcher: loadMoreProducts
                )
            } else {
                .init(
                    context: "storefront",
                    data: .init(
                        items: [],
                        // TODO: If initial params contains feed items, we could
                        // look at them to determine which kinds of placeholders
                        // we could show.
                        placeholderItems: []
//                        placeholderItems: (0 ... 12)
//                            .map { _ in ParraFeedItem.redactedContentCard }
                    ),
                    pageFetcher: loadMoreProducts
                )
            }
        }

        // MARK: - Internal

        private(set) var content: Content
        let client: Graph.Client
        let config: ParraStorefrontConfig

        /// Basic rate limitting of mutations since Shopify will reject them if
        /// they happen to quickly.
        var lastMutation: Date?

        var productsState: ProductState = .loading

        var cartState: CartState = .loading {
            didSet {
                if case .ready(let readyStateInfo) = cartState {
                    updateCartCache(
                        checkoutURL: readyStateInfo.checkoutUrl
                    )
                }
            }
        }

        var productPaginator: ParraPaginator<
            ParraProduct,
            String
                // Using IUO because this object requires referencing self in a closure
                // in its init so we need all fields set. Post-init this should always
                // be set.
        >! {
            willSet {
                paginatorSink?.cancel()
                paginatorSink = nil
            }

            didSet {
                paginatorSink = productPaginator
                    .objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }

        func findProduct(for lineItem: ParraCartLineItem) -> ParraProduct? {
            switch productsState {
            case .loading, .error:
                return nil
            case .refreshing(let products), .loaded(let products):
                return products.first { product in
                    return product.id == lineItem.variantId || product.variants
                        .contains {
                            $0.id == lineItem.variantId
                        }
                }
            }
        }

        // MARK: Cart Management

        /// Creates a new cart with the provided product/etc and proceeds to
        /// checkout immediately.
        func buyProductNow(
            productVariant: ParraProductVariant,
            quantity: UInt,
            as user: ParraUser?
        ) async throws {
            let result = try await performMutation(
                .createCartMutation(
                    for: .createCartInput(
                        productVariants: [
                            (productVariant, quantity)
                        ],
                        as: user
                    )
                )
            )

            guard let checkoutUrl = result.cartCreate?.cart?.checkoutUrl else {
                throw ParraStorefrontError.failedToBuyItNow(productVariant)
            }

            presentCart(at: checkoutUrl)
        }

        func updateQuantityForCartLineItem(
            cartItem: ParraCartLineItem,
            quantity: UInt,
            as user: ParraUser?
        ) async throws {
            logger.info("Updating quantity for cart item", [
                "cartItemId": cartItem.id,
                "quantity": quantity
            ])

            try await withReadyCart { readyInfo in
                let result = try await performMutation(
                    .updateLineItemQuantityCartMutation(
                        lineItemId: cartItem.id,
                        cartId: readyInfo.cartId,
                        quantity: quantity
                    )
                )

                guard let cart = result.cartLinesUpdate?.cart else {
                    throw ParraStorefrontError.failedToUpdateQuantity(cartItem)
                }

                readyCart(cart, as: user)

                logger.info("Updated quantity for cart item successfully", [
                    "cartItemId": cartItem.id,
                    "quantity": quantity
                ])
            }
        }

        func updateNoteForCart(
            note: String?,
            as user: ParraUser?
        ) async throws {
            logger.info("Updating cart note", ["note": note ?? "<empty>"])

            try await withReadyCart { readyInfo in
                let result = try await performMutation(
                    .updateNoteCartMutation(
                        for: readyInfo.cartId,
                        note: note
                    )
                )

                guard let cart = result.cartNoteUpdate?.cart else {
                    throw ParraStorefrontError.failedToUpdateNote(note)
                }

                readyCart(cart, as: user)

                logger.info("Updated cart note successfully")
            }
        }

        func addProductToCart(
            productVariant: ParraProductVariant,
            quantity: UInt,
            as user: ParraUser?
        ) async throws {
            logger.info("Adding product to cart", [
                "variantId": productVariant.id,
                "variantName": productVariant.title,
                "quantity": quantity
            ])

            try await withReadyCart { readyState in
                let result = try await performMutation(
                    .addToCartCartMutation(
                        cartId: readyState.cartId,
                        productVariant: productVariant,
                        quantity: quantity
                    )
                )

                guard let cart = result.cartLinesAdd?.cart else {
                    throw ParraStorefrontError.failedToAddProductToCart(productVariant)
                }

                readyCart(cart, as: user)

                logger.info("Completed adding product to cart", [
                    "variant": productVariant.id,
                    "quantity": quantity,
                    "totalCartQuantity": cart.totalQuantity
                ])
            }
        }

        func removeProductFromCart(
            cartItem: ParraCartLineItem,
            as user: ParraUser?
        ) async throws {
            logger.info("Removing product from cart", ["itemId": cartItem.id])

            try await withReadyCart { readyState in
                let result = try await performMutation(
                    .removeLineItemCartMutation(
                        lineItemId: cartItem.id,
                        cartId: readyState.cartId
                    )
                )

                guard let cart = result.cartLinesRemove?.cart else {
                    throw ParraStorefrontError.failedToRemoveItemFromCart(cartItem)
                }

                readyCart(cart, as: user)

                logger.info("Completed removing product from cart", [
                    "itemId": cartItem.id,
                    "quantity": cartItem.quantity,
                    "totalCartQuantity": cart.totalQuantity
                ])
            }
        }

        func presentCart(
            at url: URL
        ) {
            guard let viewController = UIViewController.topMostViewController() else {
                return
            }

            ShopifyCheckoutSheetKit.present(
                checkout: url,
                from: viewController,
                delegate: self
            )
        }

        func performCartSetup(
            as user: ParraUser?,
            forceRefresh: Bool = false
        ) {
            logger.info("Performing cart setup")

            Task { @MainActor in
                self.cartState = .loading

                if let existingCart = readPersistedCart(for: user), !forceRefresh {
                    logger.info("Non-expired cart existed for user")

                    applyReadyCart(existingCart)

                    preload(checkout: existingCart.checkoutUrl)

                    return
                }

                do {
                    let result = try await performMutation(
                        .createCartMutation(
                            for: .createCartInput(
                                as: user
                            )
                        )
                    )

                    guard let cart = result.cartCreate?.cart else {
                        throw ParraStorefrontError.failedToCreateCart
                    }

                    logger.info("Finished creating cart", [
                        "cartId": cart.id.rawValue,
                        "checkoutUrl": cart.checkoutUrl.absoluteString
                    ])

                    readyCart(cart, as: user)
                } catch {
                    logger.error("Failed to create cart", error)

                    self.cartState = .error(.failedToCreateCart)
                }
            }
        }

        // MARK: - Private

        private var currentPage: ParraProductResponse.PageInfo?

        private var paginatorSink: AnyCancellable? = nil

        private func updateCartCache(
            checkoutURL: URL
        ) {
            logger.debug("Preloading cart data")

            ShopifyCheckoutSheetKit.preload(checkout: checkoutURL)
        }

        // MARK: Product Loading

        private func performInitialProductLoad() {
            Task {
                do {
//                    let response = try await loadMoreProducts()

//                    currentPage = response.productPageInfo
//                    productsState = .loaded(response.products.elements)
                } catch let error as ParraStorefrontError {
                    logger.error("Error fetching products", error)

                    productsState = .error(error)
                } catch {
                    logger.error("Unexpected error fetching products", error)

                    productsState = .error(.unknown(error))
                }
            }
        }

        private func loadMoreProducts(
            _ limit: Int,
            _ offset: Int,
            _ context: String
        ) async throws -> [ParraProduct] {
            let result = try await performQuery(
                .productsQuery(
                    count: Int32(limit),
                    cursor: "" // TODO: Need to update paginator
                )
            )

            let products = result.products

//            return ParraProductResponse(
//                products: products.edges,
//                productPageInfo: ParraProductResponse.PageInfo(
//                    startCursor: products.pageInfo.startCursor,
//                    endCursor: products.pageInfo.endCursor,
//                    hasNextPage: products.pageInfo.hasNextPage
//                )
//            )

//            let response = try await api.paginateFeed(
//                feedId: feedId,
//                limit: limit,
//                offset: offset
//            )
//
//            return response.data.elements
            return []
        }

//        private func loadMoreProducts(
//            count: Int32 = 50,
//            cursor: String? = nil
//        ) async throws -> ParraProductResponse {
//        }

        private func readyCart(
            _ cart: Storefront.Cart,
            as user: ParraUser?,
            persist: Bool = true
        ) {
            let readyStateInfo = CartState.ReadyStateInfo(
                cartId: cart.id.rawValue,
                checkoutUrl: cart.checkoutUrl,
                lineItems: cart.lines.edges,
                cost: ParraCartCost(
                    shopCost: cart.cost
                ),
                quantity: cart.totalQuantity,
                note: cart.note
            )

            applyReadyCart(readyStateInfo)

            if persist {
                writePersistedCart(
                    with: readyStateInfo,
                    as: user
                )
            }
        }

        private func applyReadyCart(
            _ readyInfo: CartState.ReadyStateInfo
        ) {
            cartState = .ready(readyInfo)
        }

        private func withReadyCart(
            _ handler: (_ readyInfo: CartState.ReadyStateInfo) async throws -> Void
        ) async throws {
            switch cartState {
            case .loading, .error:
                throw ParraStorefrontError.cartNotReady
            case .ready(let readyStateInfo):
                try await handler(readyStateInfo)
            }
        }
    }
}
