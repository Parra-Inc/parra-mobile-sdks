//
//  ParraProductPriceRange.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy

public struct ParraProductPriceRange: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    public init(shopPriceRange: Storefront.ProductPriceRange) {
        self.minVariantPrice = ParraProductPrice(
            shopPrice: shopPriceRange.minVariantPrice
        )
        self.maxVariantPrice = ParraProductPrice(
            shopPrice: shopPriceRange.maxVariantPrice
        )
    }

    init(minVariantPrice: ParraProductPrice, maxVariantPrice: ParraProductPrice) {
        self.minVariantPrice = minVariantPrice
        self.maxVariantPrice = maxVariantPrice
    }

    // MARK: - Public

    public let minVariantPrice: ParraProductPrice
    public let maxVariantPrice: ParraProductPrice
}
