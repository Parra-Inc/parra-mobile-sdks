//
//  PriceLabelView.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 10/3/24.
//

import SwiftUI

struct PriceLabelView: View {
    // MARK: - Lifecycle

    init(
        price: ParraProductPrice,
        location: Location
    ) {
        self.price = price
        self.location = location
    }

    // MARK: - Internal

    enum Location {
        case cart
        case cartItemTotal
        case cartItemSubtotal
        case checkout
    }

    let price: ParraProductPrice
    let location: Location

    var body: some View {
        let priceString = price.amount.formatted(
            .currency(code: price.currencyCode)
        )

        let base = Text(priceString)

        switch location {
        case .cart:
            base
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        case .cartItemTotal:
            base
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.black)
        case .cartItemSubtotal:
            base
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
                .strikethrough()
        case .checkout:
            base
                .font(.callout)
                .fontWeight(.medium)
        }
    }
}
