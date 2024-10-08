//
//  ParraStorefrontConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation

public struct ParraStorefrontConfig {
    // MARK: - Lifecycle

    init(
        shopifyDomain: String,
        shopifyApiKey: String,
        shopifySession: URLSession = .shared,
        shopifyLocale: Locale? = .autoupdatingCurrent,
        shopifyCachePolicy: Graph.CachePolicy = .cacheFirst(expireIn: 60 * 60 * 24)
    ) {
        self.shopifyDomain = shopifyDomain
        self.shopifyApiKey = shopifyApiKey
        self.shopifySession = shopifySession
        self.shopifyLocale = shopifyLocale
        self.shopifyCachePolicy = shopifyCachePolicy
    }

    // MARK: - Internal

    /// The domain of your shop (ex: "shopname.myshopify.com").
    let shopifyDomain: String

    /// The API key for you app, obtained from the Shopify admin.
    let shopifyApiKey: String

    /// A `URLSession` to use for this client. If left blank, a session with a `default` configuration will be created.
    let shopifySession: URLSession

    /// The buyer's current locale. Supported values are limited to locales available to your shop.
    let shopifyLocale: Locale?

    let shopifyCachePolicy: Graph.CachePolicy
}
