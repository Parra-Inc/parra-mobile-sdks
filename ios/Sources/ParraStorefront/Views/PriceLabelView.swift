//
//  PriceLabelView.swift
//  Parra
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
                .foregroundStyle(theme.palette.secondaryText)
        case .cartItemTotal:
            base
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(theme.palette.primaryText)
        case .cartItemSubtotal:
            base
                .font(.callout)
                .fontWeight(.regular)
                .foregroundStyle(theme.palette.secondaryText)
                .strikethrough()
        case .checkout:
            base
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(theme.palette.primaryText)
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
