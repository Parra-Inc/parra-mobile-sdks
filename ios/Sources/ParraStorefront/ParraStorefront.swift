//
//  ParraStorefront.swift
//  Parra
//
//  Created by Mick MacCallum on 10/24/24.
//

import Buy
import Foundation
import Parra

private let logger = ParraLogger()

@MainActor
public class ParraStorefront {
    // MARK: - Public

    public struct Config {
        // MARK: - Lifecycle

        public init(
            shopifyDomain: String,
            shopifyApiKey: String,
            shopifySession: URLSession = .shared,
            shopifyLocale: Locale? = .current,
            shopifyCachePolicy: Graph.CachePolicy = .cacheFirst(
                expireIn: 60 * 60 * 24
            )
        ) {
            self.shopifyDomain = shopifyDomain
            self.shopifyApiKey = shopifyApiKey
            self.shopifySession = shopifySession
            self.shopifyLocale = shopifyLocale
            self.shopifyCachePolicy = shopifyCachePolicy
        }

        // MARK: - Public

        /// The domain of your shop (ex: "shopname.myshopify.com").
        public let shopifyDomain: String

        /// The API key for you app, obtained from the Shopify admin.
        public let shopifyApiKey: String

        /// A `URLSession` to use for this client. If left blank, a session with a `default` configuration will be created.
        public let shopifySession: URLSession

        /// The buyer's current locale. Supported values are limited to locales available to your shop.
        public let shopifyLocale: Locale?

        public let shopifyCachePolicy: Graph.CachePolicy
    }

    public static var isInitialized: Bool {
        return config != nil && shopifyService != nil
    }

    public static func initialize(with config: Config) {
        self.config = config

        let client = Graph.Client(
            shopDomain: config.shopifyDomain,
            apiKey: config.shopifyApiKey,
            session: config.shopifySession,
            locale: config.shopifyLocale
        )
        client.cachePolicy = config.shopifyCachePolicy

        shopifyService = ShopifyService(
            client: client
        )

        logger.info("Initialized Parra Storefront")
    }

    public static func preloadProducts() {
        logger.info("Preloading products")

        Task {
            do {
                cachedPreloadResponse = try await performProductPreload()
            } catch {
                logger.error("Error preloading products", error)
            }
        }
    }

    // MARK: - Internal

    static var config: Config?
    static var shopifyService: ShopifyService?

    static var cachedPreloadResponse: ParraProductResponse?

    static func performProductPreload() async throws -> ParraProductResponse {
        let rawResponse = try await getShopifyService().performQuery(
            .productsQuery(
                count: storefrontPaginatorLimit
            )
        )

        let response = ParraProductResponse(
            products: rawResponse.products.edges
                .map { ParraProduct(shopProduct: $0.node) },
            productPageInfo: ParraProductResponse.PageInfo(
                startCursor: rawResponse.products.pageInfo.startCursor,
                endCursor: rawResponse.products.pageInfo.endCursor,
                hasNextPage: rawResponse.products.pageInfo.hasNextPage
            )
        )

        cachedPreloadResponse = response

        return response
    }

    static func getShopifyService() throws -> ShopifyService {
        guard let shopifyService else {
            throw ParraError.message("Must call `ParraStorefront.initialize(with:)`")
        }

        return shopifyService
    }
}
