//
//  StorefrontWidget+ContentObserver+CartState.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Buy
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

extension StorefrontWidget.ContentObserver {
    enum CartState: Equatable {
        case loading
        case ready(ReadyStateInfo)
        case error(ParraStorefrontError)
        case checkoutComplete(ParraOrderDetails)
        case checkoutFailed(ShopifyCheckoutSheetKit.CheckoutError)

        // MARK: - Internal

        struct ReadyStateInfo: Codable, Equatable {
            // MARK: - Lifecycle

            init(
                cartId: String,
                checkoutUrl: URL,
                lineItems: [ParraCartLineItem],
                cost: ParraCartCost,
                quantity: Int = 0,
                lastUpdated: Date = .now,
                note: String? = nil
            ) {
                self.cartId = cartId
                self.checkoutUrl = checkoutUrl
                self.lineItems = lineItems
                self.cost = cost
                self.quantity = quantity
                self.lastUpdated = lastUpdated
                self.note = note
            }

            init(
                cartId: String,
                checkoutUrl: URL,
                lineItems: [Storefront.BaseCartLineEdge],
                cost: ParraCartCost,
                quantity: Int32,
                lastUpdated: Date = .now,
                note: String? = nil
            ) {
                self.cartId = cartId
                self.checkoutUrl = checkoutUrl
                self.lineItems = lineItems
                    .compactMap { ParraCartLineItem(lineItem: $0.node) }
                self.cost = cost
                self.quantity = Int(quantity)
                self.lastUpdated = lastUpdated
                self.note = note
            }

            // MARK: - Internal

            let cartId: String
            let checkoutUrl: URL
            let lineItems: [ParraCartLineItem]
            let cost: ParraCartCost
            let quantity: Int
            let lastUpdated: Date
            let note: String?
        }

        static func == (
            lhs: CartState,
            rhs: CartState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.ready(let lhsInfo), .ready(let rhsInfo)):
                return lhsInfo == rhsInfo
            case (.error(let lhe), .error(let rhe)):
                return lhe.localizedDescription == rhe.localizedDescription
            case (.checkoutComplete(let lhs), .checkoutComplete(let rhe)):
                return lhs.id == rhe.id
            case (.checkoutFailed(let le), .checkoutFailed(let re)):
                return le.localizedDescription == re.localizedDescription
            default:
                return false
            }
        }
    }
}
