//
//  ParraProductPrice.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation

public struct ParraProductPrice: Equatable, Hashable, Codable {
    // MARK: - Lifecycle

    public init(shopPrice: Storefront.MoneyV2) {
        self.amount = shopPrice.amount
        self.currencyCode = shopPrice.currencyCode.rawValue
    }

    init(amount: Decimal, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    // MARK: - Public

    public let amount: Decimal
    public let currencyCode: String
}
