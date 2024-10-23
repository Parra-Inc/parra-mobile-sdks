//
//  ParraStorefrontConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation
import Parra

public final class ParraStorefrontConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        shopifyDomain: String,
        shopifyApiKey: String,
        shopifySession: URLSession = .shared,
        shopifyLocale: Locale? = .autoupdatingCurrent,
        shopifyCachePolicy: Graph.CachePolicy = .cacheFirst(expireIn: 60 * 60 * 24),
        navigationTitle: String = "Products",
        showDismissButton: Bool = false,
        checkoutAttributes: [String: String] = [:],
        emptyStateContent: ParraEmptyStateContent = ParraStorefrontConfig
            .defaultEmptyStateContent,
        productNotFoundContent: ParraEmptyStateContent = ParraStorefrontConfig
            .defaultProductNotFoundContent,
        errorStateContent: ParraEmptyStateContent = ParraStorefrontConfig
            .defaultErrorStateContent

    ) {
        self.shopifyDomain = shopifyDomain
        self.shopifyApiKey = shopifyApiKey
        self.shopifySession = shopifySession
        self.shopifyLocale = shopifyLocale
        self.shopifyCachePolicy = shopifyCachePolicy
        self.navigationTitle = navigationTitle
        self.showDismissButton = showDismissButton
        self.checkoutAttributes = checkoutAttributes
        self.emptyStateContent = emptyStateContent
        self.productNotFoundContent = productNotFoundContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Nothing here yet"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later for new products!"
        )
    )

    public static let defaultProductNotFoundContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Oops! We couldn't find that product."
        ),
        subtitle: ParraLabelContent(
            text: "We couldn't find the product you're looking for. It may be out of stock or no longer available."
        ),
        icon: .symbol("tshirt", .monochrome)
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load products. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    /// The domain of your shop (ex: "shopname.myshopify.com").
    public let shopifyDomain: String

    /// The API key for you app, obtained from the Shopify admin.
    public let shopifyApiKey: String

    /// A `URLSession` to use for this client. If left blank, a session with a `default` configuration will be created.
    public let shopifySession: URLSession

    /// The buyer's current locale. Supported values are limited to locales available to your shop.
    public let shopifyLocale: Locale?

    public let shopifyCachePolicy: Graph.CachePolicy

    public let navigationTitle: String
    public let showDismissButton: Bool

    public let checkoutAttributes: [String: String]

    public let emptyStateContent: ParraEmptyStateContent
    public let productNotFoundContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
