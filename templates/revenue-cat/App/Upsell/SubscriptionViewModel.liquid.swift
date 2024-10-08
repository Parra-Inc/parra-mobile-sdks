//
//  SubscriptionViewModel.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import RevenueCat
import Parra

private let PRODUCT_IDS = [
    "{{ app.bundle_id }}.pro.monthly",
    "{{ app.bundle_id }}.pro.yearly"
]

@Observable
class SubscriptionViewModel {
    enum SubscriptionState {
        case loading
        case subscribed
        case unsubscribed([StoreProduct])
        case error(String)
    }

    var state: SubscriptionState = .loading

    private let revenueCat = Purchases.shared

    func purchaseProduct(_ product: StoreProduct) {
        revenueCat.purchase(
            product: product
        ) { tx, customerInfo, error, userCanceled in
            if userCanceled {
                return // do nothing
            }

            if let error {
                self.state = .error(error.localizedDescription)

                return
            }

            guard let customerInfo else {
                return
            }

            Task {
                await self.processCustomInfo(customerInfo)
            }
        }
    }

    func initialize() async {
        do {
            let customerInfo = try await revenueCat.customerInfo()

            await processCustomInfo(customerInfo)
        } catch let error as RevenueCat.ErrorCode {
            state = .error(error.description)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func processCustomInfo(_ customerInfo: CustomerInfo) async {
        if customerInfo.entitlements.active.isEmpty {
            let products = await fetchProducts()

            state = .unsubscribed(products)
        } else {
            state = .subscribed
        }
    }

    private func fetchProducts() async -> [StoreProduct] {
        return await withCheckedContinuation { continuation in
            revenueCat.getProducts(PRODUCT_IDS) { products in
                continuation.resume(
                    with: .success(
                        // highest price first
                        products.sorted { $0.price > $1.price }
                    )
                )
            }
        }
    }
}
