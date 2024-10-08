//
//  ParraCartCost.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import SwiftUI

struct ParraCartCost: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    init(shopCost: Storefront.CartCost) {
        self.subtotalPrice = ParraProductPrice(shopPrice: shopCost.subtotalAmount)
        self.totalPrice = ParraProductPrice(shopPrice: shopCost.totalAmount)
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
    }

    // MARK: - Internal

    let subtotalPrice: ParraProductPrice
    let totalPrice: ParraProductPrice
}
