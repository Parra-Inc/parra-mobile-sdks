//
//  OrderReceiptView.swift
//  Parra
//
//  Created by Mick MacCallum on 11/7/24.
//

import Buy
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

struct OrderReceiptView: View {
    // MARK: - Internal

    let details: ParraOrderDetails

    @ViewBuilder
    @MainActor var content: some View {
        let shippingAddress = details.deliveries?.first?.details.location

        VStack(alignment: .leading, spacing: 30) {
            OrderReceiptItemsListView(cart: details.cart)
                .padding(.bottom, 36)

            if let paymentMethods = details.paymentMethods, !paymentMethods.isEmpty {
                let cardPaymentMethods = paymentMethods.compactMap {
                    ParraOrderCardPaymentMethod($0)
                }

                if !cardPaymentMethods.isEmpty {
                    VStack(alignment: .leading) {
                        SectionHeaderView(
                            title: cardPaymentMethods
                                .count == 1 ? "Payment method" : "Payment methods"
                        )
                        .padding(.bottom, 10)

                        ForEach(cardPaymentMethods) { method in
                            VStack(alignment: .leading, spacing: 6) {
                                componentFactory.buildLabel(
                                    text: method.paymentMethodName,
                                    localAttributes: ParraAttributes.Label(
                                        text: ParraAttributes.Text(
                                            style: .body,
                                            weight: .bold
                                        ),
                                        padding: .custom(
                                            EdgeInsets(
                                                top: 0,
                                                leading: 0,
                                                bottom: 5,
                                                trailing: 0
                                            )
                                        )
                                    )
                                )

                                componentFactory.buildLabel(
                                    text: method.cardHolderName,
                                    localAttributes: ParraAttributes.Label(
                                        text: ParraAttributes.Text(
                                            style: .callout,
                                            color: theme.palette.primaryText
                                                .toParraColor()
                                        )
                                    )
                                )

                                HStack(spacing: 8) {
                                    componentFactory.buildLabel(
                                        text: method.number,
                                        localAttributes: ParraAttributes.Label(
                                            text: ParraAttributes.Text(
                                                style: .subheadline,
                                                weight: .semibold
                                            )
                                        )
                                    )

                                    if let month = method.expirationMonth,
                                       let year = method.expirationYear
                                    {
                                        componentFactory.buildLabel(
                                            text: "Expires \(month)/\(year)",
                                            localAttributes: ParraAttributes.Label(
                                                text: ParraAttributes.Text(
                                                    style: .caption2
                                                )
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if let shippingAddress {
                AddressView(
                    title: "Shipping address",
                    address: .different(shippingAddress)
                )
            }

            if let billingAddress = details.billingAddress {
                AddressView(
                    title: "Billing address",
                    address: billingAddress == shippingAddress ?
                        .same(as: "shipping address") :
                        .different(billingAddress)
                )
            }

            if let method = details.deliveries?.first?.method {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeaderView(title: "Shipping method")

                    componentFactory.buildLabel(text: method)
                }
            }

            if let email = details.email {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeaderView(title: "Email address")

                    componentFactory.buildLabel(text: email)
                }
            }
        }
        .safeAreaPadding()
        .frame(
            maxWidth: .infinity
        )

        .background(
            theme.palette.primaryBackground.toParraColor()
        )
    }

    var body: some View {
        ParraMediaAwareScrollView {
            content
        }
        .background(
            theme.palette.primaryBackground.toParraColor()
        )
        .navigationTitle("Receipt")
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ShareLink(
                    item: Screenshot(
                        image: generateSnapshot(),
                        fileName: "\(appInfo.application.name) receipt"
                    ),
                    subject: Text("\(appInfo.application.name) receipt"),
                    preview: SharePreview(
                        "\(appInfo.application.name) receipt",
                        image: Image(uiImage: generateSnapshot())
                    )
                )
            }

            ToolbarItem(placement: .topBarTrailing) {
                ParraDismissButton()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAppInfo) private var appInfo

    @State private var shareItems: [Any]?

    @MainActor
    @ViewBuilder
    private func screenshotContent() -> some View {
        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                text: "Receipt",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .largeTitle
                    )
                )
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            content
        }
        .padding([.bottom, .horizontal], 12)
        .padding(.top, 24)
        .background(
            theme.palette.primaryBackground.toParraColor()
        )
    }

    @MainActor
    private func generateSnapshot() -> UIImage {
        let renderer = ImageRenderer(content: screenshotContent())
        renderer.scale = UIScreen.main.scale

        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    ParraAppPreview(
        configuration: ParraConfiguration(
            theme: .default
        )
    ) {
        NavigationStack {
            OrderReceiptView(details: .validStates()[0])
        }
    }
}
