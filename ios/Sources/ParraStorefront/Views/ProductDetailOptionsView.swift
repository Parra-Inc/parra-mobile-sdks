//
//  ProductDetailOptionsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Parra
import SwiftUI

struct ProductDetailOptionsView: View {
    // MARK: - Lifecycle

    init(
        product: ParraProduct
    ) {
        self.product = product

        self._selectedVariant = State(
            wrappedValue: product.variants[0]
        )
    }

    // MARK: - Internal

    let product: ParraProduct

    var body: some View {
        VStack(spacing: 12) {
            if product.variants.count > 1 {
                HStack {
                    Text("Variant")
                        .font(.caption)
                        .bold()

                    Spacer()

                    Picker("Variant", selection: $selectedVariant) {
                        ForEach(product.variants) { variant in
                            Text(variant.title)
                                .tag(variant)
                        }
                    }
                    .pickerStyle(.menu)
                    .id("\(product.id)-variant-picker")
                }

                Divider()
            }

            HStack {
                Text("Quantity")
                    .font(.caption)
                    .bold()

                Spacer()

                ProductQuantityStepper(
                    value: $selectedQuantity,
                    maxQuantity: availableQuantity
                )
            }

            Divider()
                .padding(.bottom, 12)

            buyButtons
        }
        .onChange(of: selectedVariant, initial: true) { _, newValue in
            availableQuantity = UInt(max(newValue.quantityAvailable ?? .max, 1))
            selectedQuantity = min(availableQuantity, selectedQuantity)

            dataModel.viewProduct(
                product: product,
                variant: newValue
            )
        }
    }

    // MARK: - Private

    @State private var selectedQuantity: UInt = 1
    @State private var selectedVariant: ParraProductVariant
    @State private var availableQuantity: UInt = .max

    @State private var isAlteringCart = false
    @State private var isBuyingNow = false

    @Environment(StorefrontWidget.ContentObserver.self) private var dataModel
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var authState

    @ViewBuilder private var buyButtons: some View {
        let primaryContent = if selectedVariant.allowPurchase {
            ParraTextButtonContent(
                text: "Add to cart",
                isLoading: isAlteringCart
            )
        } else {
            ParraTextButtonContent(
                text: "Out of stock",
                isDisabled: true
            )
        }

        componentFactory.buildContainedButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .medium,
                isMaxWidth: true
            ),
            content: primaryContent,
            localAttributes: ParraAttributes.ContainedButton(
                normal: ParraAttributes.ContainedButton.StatefulAttributes(
                    padding: .zero
                )
            )
        ) {
            addToCart()
        }

        if selectedVariant.allowPurchase {
            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .secondary,
                    size: .medium,
                    isMaxWidth: true
                ),
                content: ParraTextButtonContent(
                    text: "Buy now",
                    isLoading: isBuyingNow
                ),
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: .zero
                    )
                )
            ) {
                buyItNow()
            }
        }
    }

    private func addToCart() {
        Task { @MainActor in
            isAlteringCart = true

            do {
                try await dataModel.addProductToCart(
                    product: product,
                    variant: selectedVariant,
                    quantity: selectedQuantity,
                    as: authState.user
                )
            } catch {
                ParraLogger.error("Failed to toggle item in cart", error, [
                    "product": product.id
                ])
            }

            isAlteringCart = false
        }
    }

    private func buyItNow() {
        Task { @MainActor in
            isBuyingNow = true

            do {
                try await dataModel.buyProductNow(
                    productVariant: selectedVariant,
                    quantity: selectedQuantity,
                    as: authState.user
                )
            } catch {
                ParraLogger.error("Failed buy it now for product", error, [
                    "product": product.id
                ])
            }

            isBuyingNow = false
        }
    }
}
