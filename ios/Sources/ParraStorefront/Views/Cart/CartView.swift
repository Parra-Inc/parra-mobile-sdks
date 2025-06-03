//
//  CartView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/2/24.
//

import Parra
import SwiftUI

private let logger = ParraLogger()

struct CartView: View {
    // MARK: - Internal

    var body: some View {
        VStack {
            switch dataModel.cartState {
            case .error, .checkoutFailed:
                cartNotReadyView
            case .checkoutComplete, .loading:
                cartEmptyView
            case .ready(let readyState):
                if readyState.quantity == 0 {
                    cartEmptyView
                } else {
                    cartReadyView(state: readyState)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(
            parraTheme.palette.primaryBackground
        )
        .navigationTitle("Cart")
        .alert("Special instructions", isPresented: $enteringNote) {
            TextField("", text: $_note)

            Button("Cancel", role: .cancel) {}

            Button("Save") {
                applyNoteUpdate(_note)
            }
        } message: {
            EmptyView()
        }
    }

    func canProceedToCheckout(
        state: StorefrontWidget.ContentObserver.CartState.ReadyStateInfo
    ) -> Bool {
        return state.lineItems.allSatisfy { $0.quantityAvailable > 0 }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(StorefrontWidget.ContentObserver.self) private var dataModel

    @State private var isUpdating: Bool = false
    @State private var enteringNote: Bool = false
    @State private var _note: String = ""

    private var cartEmptyView: some View {
        componentFactory.buildEmptyState(
            config: .default,
            content: ParraEmptyStateContent(
                title: ParraLabelContent(text: "Cart is empty."),
                subtitle: nil,
                icon: .symbol("cart.badge.questionmark", .monochrome)
            )
        )
    }

    @MainActor private var cartNotReadyView: some View {
        componentFactory
            .buildEmptyState(
                config: .errorDefault,
                content: dataModel.content.errorStateView
            )
    }

    @ViewBuilder
    @MainActor
    private func cartReadyView(
        state: StorefrontWidget.ContentObserver.CartState.ReadyStateInfo
    ) -> some View {
        let allStillAvailable = canProceedToCheckout(state: state)

        ParraMediaAwareScrollView {
            LazyVStack {
                ForEach(state.lineItems) { lineItem in
                    CartLineItemView(
                        lineItem: lineItem,
                        updateQuantity: applyQuantityUpdate
                    )
                    .id(lineItem.id)
                }

                let note = if let note = state.note {
                    note
                } else {
                    ""
                }

                VStack(alignment: .leading) {
                    componentFactory.buildPlainButton(
                        config: ParraTextButtonConfig(
                            type: .secondary,
                            size: .small,
                            isMaxWidth: false
                        ),
                        text: note.isEmpty ? "Add a note" : "Update note",
                        localAttributes: ParraAttributes.PlainButton(
                            normal: .init(
                                label: ParraAttributes.Label(
                                    padding: .zero
                                ),
                                padding: .zero
                            )
                        )
                    ) {
                        _note = note
                        enteringNote = true
                    }

                    if !note.isEmpty {
                        componentFactory.buildLabel(
                            text: "\"\(note)\""
                        )
                        .italic()
                        .padding(.top, 2)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.top, 12)
                .padding(.bottom, 6)

                HStack {
                    componentFactory.buildLabel(
                        text: "Subtotal"
                    )
                    .font(.callout)
                    .fontWeight(.medium)

                    Spacer()

                    if isUpdating {
                        ProgressView()
                    } else {
                        PriceLabelView(
                            price: state.cost.subtotalPrice,
                            location: .checkout
                        )
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 12)

                componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: ParraTextButtonContent(
                        text: "Continue to checkout",
                        isDisabled: !allStillAvailable,
                        isLoading: false
                    ),
                    localAttributes: ParraAttributes.ContainedButton(
                        normal: ParraAttributes.ContainedButton.StatefulAttributes(
                            padding: .zero
                        )
                    )
                ) {
                    switch dataModel.cartState {
                    case .ready(let cartState):
                        Task {
                            await dataModel.presentCart(
                                at: cartState.checkoutUrl
                            )
                        }
                    case .error, .loading, .checkoutComplete, .checkoutFailed:
                        break
                    }
                }
            }
            .safeAreaPadding([.horizontal, .bottom])
            // Force redraw the list if the cart object is updated.
            // There are cases where cells that get reused don't full update
            // because the id of an item doesn't change but its quantity does.
            .id(state.lastUpdated)
        }
    }

    private func applyQuantityUpdate(
        quantity: UInt,
        lineItem: ParraCartLineItem
    ) async throws {
        do {
            isUpdating = true

            if quantity == 0 {
                try await dataModel.removeProductFromCart(
                    cartItem: lineItem,
                    as: parraAuthState.user
                )
            } else {
                try await dataModel.updateQuantityForCartLineItem(
                    cartItem: lineItem,
                    quantity: quantity,
                    as: parraAuthState.user
                )
            }

            isUpdating = false
        } catch {
            isUpdating = false

            throw error
        }
    }

    private func applyNoteUpdate(_ note: String) {
        Task {
            do {
                try await dataModel.updateNoteForCart(note: note, as: parraAuthState.user)

                _note = ""
            } catch {
                logger.error("Error updating note", error)
            }
        }
    }
}

#Preview {
    ParraAppPreview {
        CartView()
            .environment(
                StorefrontWidget.ContentObserver(
                    initialParams: .init(
                        config: .default,
                        delegate: nil,
                        productsResponse: nil
                    )
                )
            )
    }
}
