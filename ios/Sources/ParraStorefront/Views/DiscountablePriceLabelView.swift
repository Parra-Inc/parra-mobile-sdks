//
//  DiscountablePriceLabelView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/4/24.
//

import SwiftUI

struct DiscountablePriceLabelView: View {
    // MARK: - Lifecycle

    init(
        product: ParraProduct
    ) {
        self.product = product
    }

    // MARK: - Internal

    let product: ParraProduct

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
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(
                    isDiscounted ? parraTheme.palette.error.toParraColor() : .secondary
                )

            if isDiscounted {
                Text(maxPriceString)
                    .font(.callout)
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
