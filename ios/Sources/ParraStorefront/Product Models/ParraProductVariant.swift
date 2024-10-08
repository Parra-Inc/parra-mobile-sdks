//
//  ParraProductVariant.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Buy
import SwiftUI

public struct ParraProductVariant: Identifiable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        id: String,
        title: String,
        availableForSale: Bool,
        currentlyNotInStock: Bool,
        quantityAvailable: Int?,
        price: ParraProductPrice
    ) {
        self.id = id
        self.title = title
        self.availableForSale = availableForSale
        self.currentlyNotInStock = currentlyNotInStock
        self.quantityAvailable = quantityAvailable
        self.price = price
        self.compareAtPrice = price
    }

    public init(shopVariant: Storefront.ProductVariant) {
        self.id = shopVariant.id.rawValue
        self.title = shopVariant.title
        self.availableForSale = shopVariant.availableForSale
        self.currentlyNotInStock = shopVariant.currentlyNotInStock

        if let quantityAvailable = shopVariant.quantityAvailable {
            self.quantityAvailable = quantityAvailable < 0 ? nil : Int(
                quantityAvailable
            )
        } else {
            self.quantityAvailable = nil
        }

        self.price = ParraProductPrice(shopPrice: shopVariant.price)
        self.compareAtPrice = if let compareAtPrice = shopVariant.compareAtPrice {
            ParraProductPrice(shopPrice: compareAtPrice)
        } else {
            nil
        }
    }

    // MARK: - Public

    public let id: String
    public let title: String
    public let availableForSale: Bool
    public let currentlyNotInStock: Bool
    public let quantityAvailable: Int?
    public let price: ParraProductPrice
    public let compareAtPrice: ParraProductPrice?
}
