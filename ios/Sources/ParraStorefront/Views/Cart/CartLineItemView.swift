//
//  CartLineItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/2/24.
//

import Parra
import SwiftUI

private let logger = ParraLogger()

struct CartLineItemView: View {
    // MARK: - Lifecycle

    init(
        lineItem: ParraCartLineItem,
        updateQuantity: @escaping (UInt, ParraCartLineItem) async throws -> Void
    ) {
        self.lineItem = lineItem
        self.updateQuantity = updateQuantity

        self._selectedQuantity = State(
            initialValue: UInt(max(lineItem.quantity, 0))
        )
        self._availableQuantity = State(
            initialValue: UInt(max(lineItem.quantityAvailable, 0))
        )
    }

    // MARK: - Internal

    let lineItem: ParraCartLineItem
    let updateQuantity: (UInt, ParraCartLineItem) async throws -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let image = lineItem.image {
                NavigationLink(value: lineItem) {
                    componentFactory.buildAsyncImage(
                        config: ParraAsyncImageConfig(
                            aspectRatio: 1.0,
                            contentMode: .fit
                        ),
                        content: ParraAsyncImageContent(
                            url: image.url,
                            originalSize: image.size
                        )
                    )
                    .cornerRadius(16)
                    .frame(
                        width: 110,
                        height: 110
                    )
                }
                .buttonStyle(ProductCellButtonStyle())
            }

            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        componentFactory.buildLabel(
                            text: lineItem.title
                        )
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(2)

                        optionsLabel

                        discounts
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    Spacer()

                    VStack {
                        let isDiscounted = lineItem.cost.totalPrice != lineItem.cost
                            .subtotalPrice

                        VStack(alignment: .trailing) {
                            PriceLabelView(
                                price: lineItem.cost.subtotalPrice,
                                location: isDiscounted ? .cartItemSubtotal :
                                    .cartItemTotal
                            )

                            if isDiscounted {
                                PriceLabelView(
                                    price: lineItem.cost.totalPrice,
                                    location: .cartItemTotal
                                )
                            }
                        }
                    }
                }

                Spacer()

                HStack {
                    if availableQuantity == 0 {
                        Text("Out of stock")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                parraTheme.palette.error.shade500.opacity(0.85)
                            )
                    }

                    Spacer()

                    if availableQuantity == 0 {
                        Button {
                            updateQuantity(0)
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    height: 16
                                )
                                .foregroundStyle(Color(UIColor.darkGray))
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    parraTheme.palette.primary.shade500.opacity(0.4)
                                )
                        }
                        .buttonStyle(.borderless)
                        .disabled(isUpdatingCart)
                    } else {
                        DebouncedProductQuantityStepper(
                            value: $selectedQuantity,
                            maxQuantity: availableQuantity,
                            debounceDelay: 0.5,
                            allowDeletion: true
                        )
                        .buttonStyle(.borderless)
                        .disabled(isUpdatingCart)
                    }
                }
            }
            .frame(
                maxWidth: .infinity
            )
        }
        .padding(.vertical, 6)
        .frame(
            maxWidth: .infinity
        )
        .background(
            parraTheme.palette.primaryBackground
        )
        .onChange(
            of: selectedQuantity
        ) { oldValue, newValue in
            if oldValue != newValue {
                updateQuantity(newValue)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    @State private var isUpdatingCart: Bool = false
    @State private var selectedQuantity: UInt
    @State private var availableQuantity: UInt

    @ViewBuilder private var optionsLabel: some View {
        let options = lineItem.optionsNames
        if !options.isEmpty {
            componentFactory.buildLabel(
                text: options.joined(separator: " / "),
                localAttributes: ParraAttributes
                    .Label(
                        text: ParraAttributes.Text(
                            style: .callout,
                            weight: .regular,
                            color: .secondary,
                            alignment: .leading
                        )
                    )
            )
            .lineLimit(1)
        }
    }

    @ViewBuilder private var discounts: some View {
        let discounts = lineItem.discounts

        if !discounts.isEmpty {
            ForEach(discounts, id: \.self) { discount in
                let discountAmount = discount.discountAmount.amount.formatted(
                    .currency(code: discount.discountAmount.currencyCode)
                )

                let labelText = if discount.discountAmount.amount > 0 {
                    "\(discount.title) (-\(discountAmount))"
                } else {
                    discount.title
                }

                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .frame(
                            width: 12,
                            height: 12
                        )
                        .scaledToFit()

                    Text(labelText)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
    }

    private func updateQuantity(
        _ quantity: UInt
    ) {
        Task {
            do {
                isUpdatingCart = true

                try await updateQuantity(quantity, lineItem)
            } catch {
                logger.error("Error updating cart quantity", error)
            }

            isUpdatingCart = false
        }
    }
}

#Preview {
    ParraAppPreview {
        ScrollView {
            LazyVStack {
                ForEach(ParraCartLineItem.validStates()) { mock in
                    CartLineItemView(lineItem: mock) { _, _ in }
                }
            }
            .safeAreaPadding(.horizontal)
        }
    }
}
