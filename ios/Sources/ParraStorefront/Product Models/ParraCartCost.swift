//
//  ParraCartCost.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import SwiftUI

public struct ParraCartCost: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    public init(shopCost: Storefront.CartCost) {
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

    // MARK: - Public

    public let subtotalPrice: ParraProductPrice
    public let totalPrice: ParraProductPrice
}
