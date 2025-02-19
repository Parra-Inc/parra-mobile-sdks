//
//  StorefrontWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Combine
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

private let paginatorContext = "storefront"
let storefrontPaginatorLimit: Int32 = 100

// Shopify, smartly, introduces a Task object that conflicts with this.
// Typealias to take precedence.
typealias Task = _Concurrency.Task

private let logger = ParraLogger(category: "Parra Storefront Content Observer")

// MARK: - StorefrontWidget.ContentObserver

enum ProductSortOrder: CaseIterable {
    case bestSelling
    case oldestToNewest
    case newestToOldest
    case lowestToHighest
    case highestToLowest
    case alphabeticalAToZ
    case alphabeticalZToA

    // MARK: - Internal

    var shopifySort: (Bool, Storefront.ProductSortKeys) {
        switch self {
        case .bestSelling:
            return (false, .bestSelling)
        case .oldestToNewest:
            return (false, .createdAt)
        case .newestToOldest:
            return (true, .createdAt)
        case .lowestToHighest:
            return (false, .price)
        case .highestToLowest:
            return (true, .price)
        case .alphabeticalAToZ:
            return (false, .title)
        case .alphabeticalZToA:
            return (true, .title)
        }
    }

    var name: String {
        switch self {
        case .bestSelling:
            return "Best Selling"
        case .oldestToNewest:
            return "Date, old to new"
        case .newestToOldest:
            return "Date, new to old"
        case .lowestToHighest:
            return "Price, low to high"
        case .highestToLowest:
            return "Price, high to low"
        case .alphabeticalAToZ:
            return "Alphabetically, A-Z"
        case .alphabeticalZToA:
            return "Alphabetically, Z-A"
        }
    }
}

// MARK: - StorefrontWidget.ContentObserver

extension StorefrontWidget {
    @Observable
    @MainActor
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.config = initialParams.config
            self.delegate = initialParams.delegate

            self.content = Content(
                emptyStateView: initialParams.config.emptyStateContent,
                productMissingView: initialParams.config.productNotFoundContent,
                errorStateView: initialParams.config.errorStateContent
            )

            self.wasPreloaded = if let elements = initialParams.productsResponse?.products
                .elements
            {
                !elements.isEmpty
            } else {
                false
            }

            self.productPaginator = if let productsResponse = initialParams
                .productsResponse
            {
                .init(
                    context: paginatorContext,
                    data: .init(
                        items: productsResponse.products.elements,
                        placeholderItems: [],
                        pageSize: Int(storefrontPaginatorLimit),
                        knownCount: productsResponse.products.elements.count
                    ),
                    pageFetcher: loadMoreProducts
                )
            } else {
                .init(
                    context: paginatorContext,
                    data: .init(
                        items: [],
                        placeholderItems: (0 ... 12)
                            .map { _ in ParraProduct.redactedProduct }
                    ),
                    pageFetcher: loadMoreProducts
                )
            }
        }

        // MARK: - Internal

        private(set) var content: Content

        let config: ParraStorefrontWidgetConfig
        nonisolated let delegate: ParraStorefrontWidgetDelegate?

        var sortOrder: ProductSortOrder = .newestToOldest {
            didSet {
                productPaginator.refresh()
            }
        }

        var cartState: CartState = .loading {
            didSet {
                if case .ready(let readyStateInfo) = cartState {
                    updateCartCache(
                        checkoutURL: readyStateInfo.checkoutUrl
                    )
                }
            }
        }

        var productPaginator: ParraCursorPaginator<
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

        @MainActor
        func refresh() async {
            await productPaginator.refresh()
        }

        @MainActor
        func loadInitialProducts() {
            if !wasPreloaded {
                productPaginator.loadMore()
            }
        }

        @MainActor
        func completeCheckout(
            with orderDetails: ParraOrderDetails
        ) {
            cartState = .checkoutComplete(orderDetails)

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        @MainActor
        func failCheckout(
            with errorMessage: String,
            error: Error,
            isRecoverable: Bool
        ) {
            cartState = .checkoutFailed(errorMessage)

            UINotificationFeedbackGenerator().notificationOccurred(.error)

            ParraAlertManager.shared.showErrorToast(
                title: "Checkout error",
                userFacingMessage: errorMessage,
                underlyingError: error,
                in: .topCenter,
                for: 5.0,
                onDismiss: {
                    if !isRecoverable {
                        self.refreshExpiredCart()
                    }
                }
            )
        }

        @MainActor
        func viewProduct(
            product: ParraProduct,
            variant: ParraProductVariant
        ) {
            StorefrontAnalytics.viewProductDetails(product, variant)

            delegate?.storefrontWidgetViewProductDetails(
                product: product,
                with: variant
            )
        }

        func findProduct(
            for lineItem: ParraCartLineItem
        ) -> ParraProduct? {
            return productPaginator.items.first { product in
                return product.id == lineItem.variantId || product.variants
                    .contains {
                        $0.id == lineItem.variantId
                    }
            }
        }

        /// Tries to match the query string against the product id, product
        /// variant ids, name, etc.
        func queryProduct(
            by query: String
        ) -> ParraProduct? {
            var actualQuery = query
            if let productId = Int64(query) {
                actualQuery = "gid://shopify/Product/\(productId)"
            }

            return productPaginator.items.first { product in
                if product.id == actualQuery {
                    return true
                }

                if product.name.lowercased() == actualQuery {
                    return true
                }

                return product.variants
                    .contains {
                        $0.id == actualQuery
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
            let shopifyService = try ParraStorefront.getShopifyService()
            let result = try await shopifyService.performMutation(
                .createCartMutation(
                    for: .createCartInput(
                        productVariants: [
                            (productVariant, quantity)
                        ],
                        as: user,
                        discountCodes: config.checkoutDiscountCodes,
                        attributes: config.checkoutAttributes
                    )
                )
            )

            guard let checkoutUrl = result.cartCreate?.cart?.checkoutUrl else {
                throw ParraStorefrontError.failedToBuyItNow(productVariant)
            }

            await presentCart(at: checkoutUrl)
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
                let shopifyService = try ParraStorefront.getShopifyService()
                let result = try await shopifyService.performMutation(
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

                if quantity > cartItem.quantity {
                    if let (product, variant) = findProductAndVariant(
                        for: cartItem
                    ) {
                        StorefrontAnalytics.addProductToCart(
                            product,
                            variant,
                            UInt(abs(cartItem.quantity - Int(quantity)))
                        )

                        delegate?.storefrontWidgetAddedProductToCart(
                            product: product,
                            with: variant,
                            in: Int(quantity)
                        )
                    }
                } else {
                    StorefrontAnalytics.removeItemFromCart(
                        cartItem,
                        UInt(abs(cartItem.quantity - Int(quantity)))
                    )

                    delegate?.storefrontWidgetRemovedLineItemFromCart(
                        lineItem: cartItem,
                        in: cartItem.quantity
                    )
                }
            }
        }

        func updateNoteForCart(
            note: String?,
            as user: ParraUser?
        ) async throws {
            logger.info("Updating cart note", ["note": note ?? "<empty>"])

            try await withReadyCart { readyInfo in
                let shopifyService = try ParraStorefront.getShopifyService()
                let result = try await shopifyService.performMutation(
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
            product: ParraProduct,
            variant: ParraProductVariant,
            quantity: UInt,
            as user: ParraUser?
        ) async throws {
            logger.info("Adding product to cart", [
                "variantId": variant.id,
                "variantName": variant.title,
                "quantity": quantity
            ])

            try await withReadyCart { readyState in
                let shopifyService = try ParraStorefront.getShopifyService()
                let result = try await shopifyService.performMutation(
                    .addToCartCartMutation(
                        cartId: readyState.cartId,
                        productVariant: variant,
                        quantity: quantity
                    )
                )

                guard let cart = result.cartLinesAdd?.cart else {
                    throw ParraStorefrontError.failedToAddProductToCart(variant)
                }

                readyCart(cart, as: user)

                logger.info("Completed adding product to cart", [
                    "variant": variant.id,
                    "quantity": quantity,
                    "totalCartQuantity": cart.totalQuantity
                ])

                StorefrontAnalytics.addProductToCart(
                    product,
                    variant,
                    quantity
                )

                delegate?.storefrontWidgetAddedProductToCart(
                    product: product,
                    with: variant,
                    in: Int(quantity)
                )
            }
        }

        func removeProductFromCart(
            cartItem: ParraCartLineItem,
            as user: ParraUser?
        ) async throws {
            logger.info("Removing product from cart", ["itemId": cartItem.id])

            try await withReadyCart { readyState in
                let shopifyService = try ParraStorefront.getShopifyService()
                let result = try await shopifyService.performMutation(
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

                StorefrontAnalytics.removeItemFromCart(
                    cartItem,
                    UInt(cartItem.quantity)
                )

                delegate?.storefrontWidgetRemovedLineItemFromCart(
                    lineItem: cartItem,
                    in: cartItem.quantity
                )
            }
        }

        func presentCart(
            at url: URL
        ) async {
            guard let viewController = UIViewController.topMostViewController() else {
                return
            }

            do {
                try await withReadyCart { readyInfo in
                    StorefrontAnalytics.initiateCheckout(
                        readyInfo.lineItems,
                        readyInfo.cost
                    )

                    delegate?
                        .storefrontWidgetDidInitiateCheckout(
                            lineItems: readyInfo.lineItems,
                            with: readyInfo.cost
                        )
                }

                ShopifyCheckoutSheetKit.present(
                    checkout: url,
                    from: viewController,
                    delegate: self
                )
            } catch {
                logger.error("Failed to present cart", error)
            }
        }

        @MainActor
        func refreshExpiredCart() {
            let user = Parra.currentUser

            deletePersistedCart(for: user)

            performCartSetup(as: user, forceRefresh: true)
        }

        func performCartSetup(
            as user: ParraUser?,
            forceRefresh: Bool = false
        ) {
            Task { @MainActor in
                if let existingCart = readPersistedCart(for: user), !forceRefresh {
                    if case .ready(let info) = cartState,
                       existingCart.cartId == info.cartId
                    {
                        // Cart for this user was already loaded.
                        return
                    }

                    logger.info("Non-expired cart existed for user")

                    applyReadyCart(existingCart)

                    preload(checkout: existingCart.checkoutUrl)

                    return
                }

                logger.info("Performing cart setup")

                self.cartState = .loading

                do {
                    let shopifyService = try ParraStorefront.getShopifyService()
                    let result = try await shopifyService.performMutation(
                        .createCartMutation(
                            for: .createCartInput(
                                as: user,
                                discountCodes: config.checkoutDiscountCodes,
                                attributes: config.checkoutAttributes
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

        private let wasPreloaded: Bool
        private var paginatorSink: AnyCancellable? = nil

        private func updateCartCache(
            checkoutURL: URL
        ) {
            logger.debug("Preloading cart data")

            ShopifyCheckoutSheetKit.preload(checkout: checkoutURL)
        }

        private func loadMoreProducts(
            _ cursor: ParraCursorPaginator<ParraProduct, String>.Cursor,
            _ pageSize: Int,
            _ context: String
        ) async throws -> ParraCursorPaginator<ParraProduct, String>.Page {
            if ParraAppEnvironment.isDebugParraDevApp {
                try await Task.sleep(for: .seconds(0.5))
            }

            let (reverse, sortKey) = sortOrder.shopifySort

            let shopifyService = try ParraStorefront.getShopifyService()
            let result = try await shopifyService.performQuery(
                .productsQuery(
                    count: Int32(pageSize),
                    startCursor: cursor.endCursor,
                    reverse: reverse,
                    sortKey: sortKey
                )
            )

            let products = result.products

            return .init(
                items: products.edges
                    .map { ParraProduct(shopProduct: $0.node) },
                cursor: .init(
                    startCursor: products.pageInfo.startCursor,
                    endCursor: products.pageInfo.endCursor,
                    hasNextPage: products.pageInfo.hasNextPage
                )
            )
        }

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
            case .loading, .error, .checkoutComplete, .checkoutFailed:
                throw ParraStorefrontError.cartNotReady
            case .ready(let readyStateInfo):
                try await handler(readyStateInfo)
            }
        }

        private func findProductAndVariant(
            for cartItem: ParraCartLineItem
        ) -> (ParraProduct, ParraProductVariant)? {
            for product in productPaginator.items {
                for variant in product.variants {
                    if variant.id == cartItem.variantId {
                        return (product, variant)
                    }
                }
            }

            return nil
        }
    }
}
