//
//  ProductCell.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI

private let cellAspectRatio: CGFloat = 0.82
private let cellCornerRadius: CGFloat = 20

struct ProductCell: View {
    @Environment(\.parraTheme) private var theme
    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var parraComponentFactory
    @Environment(\.redactionReasons) private var redactionReasons

    let product: ParraProduct

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            productImage
                .cornerRadius(cellCornerRadius)
                .overlay(alignment: .bottomLeading) {
                    if product.discountPercentage > 0 {
                        HStack(
                            alignment: .center,
                            spacing: 3
                        ) {
                            Image(systemName: "tag.fill")
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(
                                    width: 10,
                                    height: 10
                                )
                                .scaledToFit()

                            Text(
                                product.discountPercentage.formatted(
                                    .percent.precision(.fractionLength(0))
                                )
                            )
                            .foregroundStyle(.white)
                            .font(.caption2)
                            .fontWeight(.semibold)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 6)
                        .background(
                            theme.palette.error.toParraColor()
                        )
                        .clipShape(.capsule)
                        .padding([.leading, .bottom], 10)
                    }
                }

            productInfo
        }
    }

    @ViewBuilder private var productImage: some View {
        VStack(alignment: .center) {
            GeometryReader { proxy in
                if let image = product.featuredImage ?? product.images.first {
                    parraComponentFactory.buildAsyncImage(
                        config: ParraImageConfig(
                            contentMode: .fill
                        ),
                        content: ParraAsyncImageContent(
                            url: image.url
                        )
                    )
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .center
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .aspectRatio(cellAspectRatio, contentMode: .fill)
        .clipped()
    }

    @ViewBuilder private var productInfo: some View {
        VStack(alignment: .leading) {
            let trimmed = product.name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            parraComponentFactory.buildLabel(
                text: trimmed,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes
                        .Text(
                            font: .headline,
                            alignment: .leading
                        )
                )
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .lineLimit(1)

            DiscountablePriceLabelView(
                product: product,
                location: .productList
            )
        }
        .padding(.vertical, 12)
    }
}
