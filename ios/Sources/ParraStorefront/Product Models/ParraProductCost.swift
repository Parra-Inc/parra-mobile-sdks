//
//  ParraProductCost.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import SwiftUI

public struct ParraProductCost: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    public init(shopCost: Storefront.CartLineCost) {
        self.subtotalPrice = ParraProductPrice(shopPrice: shopCost.subtotalAmount)
        self.totalPrice = ParraProductPrice(shopPrice: shopCost.totalAmount)
        self.amountPerQuantity = ParraProductPrice(shopPrice: shopCost.amountPerQuantity)
    }

    init(
        totalPrice: Double,
        subtotalPrice: Double
    ) {
        self.subtotalPrice = .init(
            amount: Decimal(subtotalPrice),
            currencyCode: "USD"
        )

        self.totalPrice = .init(
            amount: Decimal(totalPrice),
            currencyCode: "USD"
        )

        self.amountPerQuantity = .init(
            amount: Decimal(subtotalPrice),
            currencyCode: "USD"
        )
    }

    // MARK: - Public

    public let subtotalPrice: ParraProductPrice
    public let totalPrice: ParraProductPrice
    public let amountPerQuantity: ParraProductPrice
}
