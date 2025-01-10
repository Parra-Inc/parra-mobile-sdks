//
//  ProductVariantPriceLabelView.swift
//  Parra
//
//  Created by Mick MacCallum on 1/9/25.
//

import SwiftUI

struct ProductVariantPriceLabelView: View {
    // MARK: - Lifecycle

    init(
        selectedVariant: Binding<ParraProductVariant>
    ) {
        _selectedVariant = selectedVariant
    }

    // MARK: - Internal

    var body: some View {
        HStack(spacing: 3) {
            let isDiscounted = selectedVariant.compareAtPrice != nil

            let priceString = selectedVariant.price.amount.formatted(
                .currency(code: selectedVariant.price.currencyCode)
            )

            Text(priceString)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    isDiscounted ? parraTheme.palette.error.toParraColor() : .secondary
                )

            if let retailPrice = selectedVariant.compareAtPrice {
                let retailPriceString = retailPrice.amount.formatted(
                    .currency(code: retailPrice.currencyCode)
                )

                Text(retailPriceString)
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                    .strikethrough()
            }
        }
    }

    // MARK: - Private

    @Binding private var selectedVariant: ParraProductVariant

    @Environment(\.parraTheme) private var parraTheme
}
