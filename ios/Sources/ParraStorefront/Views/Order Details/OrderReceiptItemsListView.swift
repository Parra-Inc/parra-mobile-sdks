//
//  OrderReceiptItemsListView.swift
//  Parra
//
//  Created by Mick MacCallum on 11/8/24.
//

import Parra
import SwiftUI

struct OrderReceiptItemsListView: View {
    // MARK: - Internal

    let cart: ParraOrderCartInfo

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                ForEach(cart.lines) { line in
                    renderLine(line)
                }
            }
            .padding(.bottom, 24)

            Divider()

            renderMoneyLine(cart.price.subtotal, named: "Subtotal")
            renderMoneyLine(cart.price.shipping, named: "Shipping")
            renderMoneyLine(cart.price.taxes, named: "Tax")

            if let discounts = cart.price.discounts, !discounts.isEmpty {
                VStack(alignment: .leading) {
                    componentFactory.buildLabel(
                        text: "Discounts",
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .body,
                                weight: .semibold
                            ),
                            padding: .custom(
                                EdgeInsets(
                                    top: 12,
                                    leading: 0,
                                    bottom: 0,
                                    trailing: 0
                                )
                            )
                        )
                    )

                    ForEach(discounts) { discount in
                        renderDiscount(discount)
                    }
                }
            }

            Divider()

            renderMoneyLine(cart.price.total, named: "Total", bold: true)
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme

    @ViewBuilder
    private func renderLine(
        _ line: ParraOrderCartLine
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let image = line.image, let imageUrl = URL(
                string: image.sm
            ) {
                componentFactory.buildAsyncImage(
                    content: ParraAsyncImageContent(
                        url: imageUrl
                    ),
                    localAttributes: ParraAttributes.AsyncImage(
                        cornerRadius: .md,
                        background: theme.palette.secondaryBackground.toParraColor()
                    )
                )
                .frame(
                    width: 60,
                    height: 60
                )
            }

            VStack(alignment: .leading) {
                componentFactory.buildLabel(
                    text: line.title,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .headline
                        )
                    )
                )
                .lineLimit(3)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                componentFactory.buildLabel(
                    text: "x \(line.quantity.formatted(.number))",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .footnote,
                            color: theme.palette.secondaryText.toParraColor()
                        )
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }

            if let amount = line.price.amount,
               let currencyCode = line.price.currencyCode
            {
                VStack {
                    let cost = amount.formatted(
                        .currency(code: currencyCode)
                    )

                    componentFactory.buildLabel(
                        text: cost,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .callout,
                                color: theme.palette.secondaryText.toParraColor()
                            )
                        )
                    )
                }
            }
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func renderDiscount(
        _ discount: ParraOrderDiscount
    ) -> some View {
        if let amount = discount.amount,
           let currencyCode = amount.currencyCode,
           let amount = amount.amount,
           let title = discount.title
        {
            HStack {
                componentFactory.buildLabel(
                    text: title
                )

                Spacer()

                let negativeAmount = amount >= 0 ? amount * -1 : amount

                let cost = negativeAmount.formatted(
                    .currency(code: currencyCode)
                )

                componentFactory.buildLabel(
                    text: cost
                )
            }
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private func renderMoneyLine(
        _ money: ParraOrderMoney?,
        named name: String,
        bold: Bool = false
    ) -> some View {
        if let money, let amount = money.amount, let currencyCode = money.currencyCode {
            HStack {
                componentFactory.buildLabel(
                    text: name,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: bold ? .title2 : .body,
                            weight: .semibold
                        )
                    )
                )

                Spacer()

                let cost = amount.formatted(
                    .currency(code: currencyCode)
                )

                componentFactory.buildLabel(
                    text: cost,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: bold ? .title2 : .body,
                            weight: bold ? .semibold : .regular
                        )
                    )
                )
            }
            .padding(.top, bold ? 12 : 4)
        }
    }
}
