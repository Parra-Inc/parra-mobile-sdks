//
//  StorefrontWidget+ContentObserver+CheckoutDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Parra
import ShopifyCheckoutSheetKit
import UIKit

private let logger = ParraLogger()

// MARK: - StorefrontWidget.ContentObserver + CheckoutDelegate

extension StorefrontWidget.ContentObserver: CheckoutDelegate {
    nonisolated func checkoutDidComplete(
        event: ShopifyCheckoutSheetKit.CheckoutCompletedEvent
    ) {
        Task { @MainActor in
            var items: [[String: Any]] = []

            for line in event.orderDetails.cart.lines {
                let variantId = line.merchandiseId ?? "unknown"
                // Use this to update UI, reset cart state, etc.
                let params: [String: Any] = [
                    "product_id": line.productId ?? "unknown",
                    "product_name": line.title,
                    "variant_id": variantId,
                    "quantity": line.quantity
                ]

                Parra.logEvent(
                    .purchase(product: variantId),
                    params
                )
            }

            performCartSetup(
                as: Parra.currentUser,
                forceRefresh: true
            )

            UIViewController.topMostViewController()?.dismiss(
                animated: true,
                completion: nil
            )
        }
    }

    nonisolated func checkoutDidCancel() {
        Task { @MainActor in
            Parra.logEvent(.tap(element: "checkout_cancelled"))

            UIViewController.topMostViewController()?.dismiss(
                animated: true,
                completion: nil
            )
        }
    }

    nonisolated func checkoutDidFail(
        error: ShopifyCheckoutSheetKit.CheckoutError
    ) {
        Task { @MainActor in
            logger.error("Checkout failed with error", error)
        }
    }

    nonisolated func shouldRecoverFromError(
        error: ShopifyCheckoutSheetKit.CheckoutError
    ) -> Bool {
        return false
    }

    nonisolated func checkoutDidClickLink(
        url: URL
    ) {
        Task { @MainActor in
            logger.info("Cart link clicked", [
                "url": url.absoluteString
            ])

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }

    nonisolated func checkoutDidEmitWebPixelEvent(
        event: ShopifyCheckoutSheetKit.PixelEvent
    ) {}
}
