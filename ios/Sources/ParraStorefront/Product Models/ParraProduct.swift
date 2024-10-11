//
//  ParraProduct.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Buy
import Foundation
import Parra
import SwiftHTMLtoMarkdown

public struct ParraProduct: Identifiable, Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    public init(shopProduct: Storefront.Product) {
        self.id = shopProduct.id.rawValue
        self.name = shopProduct.title
        self.description = shopProduct.description
        self.descriptionHtml = shopProduct.descriptionHtml
        self.descriptionMarkdown = Self.markdownFromHTML(shopProduct.descriptionHtml)
        self.priceRange = ParraProductPriceRange(
            shopPriceRange: shopProduct.priceRange
        )
        self.compareAtPriceRange = ParraProductPriceRange(
            shopPriceRange: shopProduct.compareAtPriceRange
        )
        self.merchantId = shopProduct.variants.nodes.first?.id.rawValue
        self.onlineStoreUrl = shopProduct.onlineStoreUrl

        self.featuredImage = if let shopImage = shopProduct.featuredImage {
            ParraProductImage(shopImage: shopImage)
        } else {
            nil
        }

        self.variants = shopProduct.variants.nodes.map {
            ParraProductVariant(shopVariant: $0)
        }

        self.images = shopProduct.images.nodes.map {
            ParraProductImage(shopImage: $0)
        }
    }

    // If you update the access of this initializer, reconsider the default
    // assignments.
    init(
        id: String,
        name: String,
        price: Double,
        imageUrl: URL?,
        description: String
    ) {
        self.id = id
        self.name = name
        self.priceRange = .init(
            minVariantPrice: ParraProductPrice(
                amount: Decimal(price),
                currencyCode: "USD"
            ),
            maxVariantPrice: ParraProductPrice(
                amount: Decimal(price),
                currencyCode: "USD"
            )
        )
        self.compareAtPriceRange = .init(
            minVariantPrice: ParraProductPrice(
                amount: Decimal(price),
                currencyCode: "USD"
            ),
            maxVariantPrice: ParraProductPrice(
                amount: Decimal(price),
                currencyCode: "USD"
            )
        )
        self.featuredImage = .init(
            url: URL(
                string: "https://thedimelab.com/cdn/shop/files/71.heic?v=1724000610"
            )!
        )
        self.images = [featuredImage!]
        self.description = description
        self.descriptionHtml = description
        self.descriptionMarkdown = nil
        self.merchantId = nil
        self.variants = [
            .init(
                id: id + "-variant-1",
                title: name + " Variant 1",
                availableForSale: true,
                currentlyNotInStock: false,
                quantityAvailable: 25,
                price: ParraProductPrice(amount: 120, currencyCode: "USD")
            ),
            .init(
                id: id + "-variant-2",
                title: name + " Variant 2",
                availableForSale: true,
                currentlyNotInStock: true,
                quantityAvailable: 0,
                price: ParraProductPrice(amount: 120, currencyCode: "USD")
            ),
            .init(
                id: id + "-variant-3",
                title: name + " Variant 3",
                availableForSale: true,
                currentlyNotInStock: false,
                quantityAvailable: 1,
                price: ParraProductPrice(amount: 120, currencyCode: "USD")
            )
        ]
        self
            .onlineStoreUrl =
            URL(string: "https://thedimelab.com/products/classic-football")!
    }

    // MARK: - Public

    public let id: String
    public let merchantId: String?
    public let name: String
    public let priceRange: ParraProductPriceRange
    public let compareAtPriceRange: ParraProductPriceRange
    public let images: [ParraProductImage]
    public let featuredImage: ParraProductImage?
    public let description: String
    public let descriptionHtml: String
    public let descriptionMarkdown: String?
    public let variants: [ParraProductVariant]
    public let onlineStoreUrl: URL?

    // MARK: - Internal

    var discountPercentage: Decimal {
        let maxPrice = compareAtPriceRange.maxVariantPrice
        let minPrice = priceRange.minVariantPrice

        if maxPrice.amount.isZero || maxPrice.amount <= minPrice.amount {
            return .zero
        }

        let percentage = 1.0 - minPrice.amount / maxPrice.amount
        if percentage.isNaN || percentage.isInfinite {
            return 0.0
        }

        if percentage < 0.01 {
            return 0.0
        }

        return percentage
    }

    static func markdownFromHTML(_ html: String) -> String? {
        do {
            var document = BasicHTML(rawHTML: html)
            try document.parse()

            return try document.asMarkdown()
        } catch {
            ParraLogger.error("Error converting description to markdown", error)

            return nil
        }
    }
}
