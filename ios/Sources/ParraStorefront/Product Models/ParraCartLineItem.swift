//
//  ParraCartLineItem.swift
//  Parra
//
//  Created by Mick MacCallum on 10/2/24.
//

import Buy
import SwiftUI

public struct ParraCartLineItem: Identifiable, Equatable, Codable, Hashable {
    // MARK: - Lifecycle

    init(
        id: String,
        variantId: String,
        title: String,
        optionsNames: [String],
        cost: ParraProductCost,
        quantity: Int,
        quantityAvailable: Int,
        image: ParraProductImage?,
        discounts: [DiscountAllocation] = []
    ) {
        self.id = id
        self.variantId = variantId
        self.title = title
        self.optionsNames = optionsNames
        self.cost = cost
        self.quantity = quantity
        self.quantityAvailable = quantityAvailable
        self.image = image
        self.discounts = discounts
    }

    public init?(lineItem: BaseCartLine) {
        guard let variant = lineItem.merchandise as? Storefront.ProductVariant else {
            return nil
        }

        self.id = lineItem.id.rawValue
        self.variantId = variant.id.rawValue
        self.title = variant.product.title
        self.optionsNames = variant.selectedOptions.filter {
            // Products without variants have this default option, which we can hide.
            $0.name.lowercased() != "title" && $0.value.lowercased() != "default title"
        }.map(\.value)
        self.quantity = Int(lineItem.quantity)
        if let quantityAvailable = variant.quantityAvailable {
            self.quantityAvailable = quantityAvailable < 0 ? .max : Int(
                quantityAvailable
            )
        } else {
            self.quantityAvailable = .max
        }

        self.cost = ParraProductCost(shopCost: lineItem.cost)
        self.image = if let shopImage = variant.image ?? variant.product.featuredImage {
            ParraProductImage(shopImage: shopImage)
        } else {
            nil
        }

        if let discountAllocations = lineItem
            .discountAllocations as? [Storefront.CartAutomaticDiscountAllocation]
        {
            self.discounts = discountAllocations.map { automaticDiscount in
                DiscountAllocation(
                    automaticDiscount: automaticDiscount
                )
            }
        } else {
            self.discounts = []
        }
    }

    // MARK: - Public

    public struct DiscountAllocation: Equatable, Codable, Hashable {
        // MARK: - Lifecycle

        init(
            discountAmount: ParraProductPrice,
            title: String
        ) {
            self.discountAmount = discountAmount
            self.title = title
        }

        public init(
            automaticDiscount: Storefront.CartAutomaticDiscountAllocation
        ) {
            self.title = automaticDiscount.title
            self.discountAmount = ParraProductPrice(
                shopPrice: automaticDiscount.discountedAmount
            )
        }

        // MARK: - Public

        public let discountAmount: ParraProductPrice
        public let title: String
    }

    public let id: String
    public let variantId: String
    public let title: String
    public let optionsNames: [String]
    public let cost: ParraProductCost
    public let quantity: Int
    public let quantityAvailable: Int
    public let image: ParraProductImage?
    public let discounts: [DiscountAllocation]
}
