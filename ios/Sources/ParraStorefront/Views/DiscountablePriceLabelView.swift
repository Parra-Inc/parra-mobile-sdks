//
//  DiscountablePriceLabelView.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 10/4/24.
//

import SwiftUI

struct DiscountablePriceLabelView: View {
    // MARK: - Lifecycle

    init(
        product: ParraProduct,
        location: Location
    ) {
        self.product = product
        self.location = location
    }

    // MARK: - Internal

    enum Location {
        case productList
        case productDetail
    }

    let product: ParraProduct
    let location: Location

    var body: some View {
        HStack(spacing: 3) {
            let max = product.compareAtPriceRange.maxVariantPrice
            let min = product.priceRange.minVariantPrice
            let isDiscounted = product.discountPercentage > 0

            let maxPriceString = max.amount.formatted(
                .currency(code: max.currencyCode)
            )

            let minPriceString = min.amount.formatted(
                .currency(code: min.currencyCode)
            )

            Text(minPriceString)
                .font(location == .productList ? .callout : .subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    isDiscounted ? parraTheme.palette.error.toParraColor() : .secondary
                )

            if isDiscounted {
                Text(maxPriceString)
                    .font(location == .productList ? .callout : .subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                    .strikethrough()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
