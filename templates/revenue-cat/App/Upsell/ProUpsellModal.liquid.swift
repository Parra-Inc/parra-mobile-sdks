//
//  ProUpsellModal.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import Parra
import RevenueCat

struct ProUpsellModal: View {
    @Environment(\.parraTheme) private var parraTheme
    @State var subscriptions = SubscriptionViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Label(
                title: { Text("Upgrade to Pro!") },
                icon: { Image(systemName: "crown.fill") }
            )
            .padding(.top, 8)
            .font(.title)
            .bold()

            Text("Enjoy all our app has to offer with access to Pro features.")

            Spacer()

            switch subscriptions.state {
            case .loading:
                ProgressView()
            case .subscribed:
                memberView
            case .unsubscribed(let products):
                if products.isEmpty {
                    emptyView
                } else {
                    renderProducts(products)
                }
            case .error(let message):
                renderErrorView(with: message)
            }

            Spacer()
        }
        .safeAreaPadding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .task {
            await subscriptions.initialize()
        }
    }

    private func renderProducts(_ products: [StoreProduct]) -> some View {
        LazyVStack {
            ForEach(
                Array(products.enumerated()),
                id: \.element
            ) { (index, product) in
                let badge = index == 0 ? "BEST VALUE" : nil

                Button(action: {
                    subscriptions.purchaseProduct(product)
                }, label: {
                    ProProductCell(
                        title: product.localizedTitle,
                        subtitle: product.localizedDescription,
                        price: product.localizedPriceString,
                        badge: badge
                    )
                })
                .buttonStyle(.plain)
            }
        }
    }

    private func renderErrorView(
        with message: String
    ) -> some View {
        Label(
            title: { Text(message) },
            icon: { Image(systemName: "rectangle.on.rectangle.slash") }
        )
        .font(.callout)
    }

    private var emptyView: some View {
        Label(
            title: { Text("No products found") },
            icon: { Image(systemName: "rectangle.on.rectangle.slash") }
        )
        .font(.callout)
    }

    private var memberView: some View {
        VStack {
            Label(
                title: { Text("Pro member") },
                icon: { Image(systemName: "heart") }
            )
            .font(.callout)

            Text("Thank you for supporting us with your Pro membership.")
        }
    }
}

#Preview {
    ParraAppPreview {
        ProUpsellModal()
    }
}
