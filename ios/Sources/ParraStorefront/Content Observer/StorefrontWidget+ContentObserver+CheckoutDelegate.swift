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
            let orderDetails = ParraOrderDetails(orderDetails: event.orderDetails)

            StorefrontAnalytics.makePurchase(orderDetails)

            performCartSetup(
                as: Parra.currentUser,
                forceRefresh: true
            )

            UIViewController.topMostViewController()?.dismiss(
                animated: true,
                completion: nil
            )

            delegate?
                .storefrontWidgetDidMakePurchase(
                    orderDetails: orderDetails
                )
        }
    }

    nonisolated func checkoutDidCancel() {
        Task { @MainActor in
            StorefrontAnalytics.cancelCheckout()

            UIViewController.topMostViewController()?.dismiss(
                animated: true,
                completion: nil
            )

            delegate?.storefrontWidgetDidCancelCheckout()
        }
    }

    nonisolated func checkoutDidFail(
        error: ShopifyCheckoutSheetKit.CheckoutError
    ) {
        Task { @MainActor in
            logger.error("Checkout failed with error", error)

            delegate?.storefrontWidgetDidFailCheckout(
                error: error
            )
        }
    }

    nonisolated func shouldRecoverFromError(
        error: ShopifyCheckoutSheetKit.CheckoutError
    ) -> Bool {
        return delegate?.storefrontWidgetShouldRecoverFromCheckoutError(
            error: error
        ) ?? false
    }

    nonisolated func checkoutDidClickLink(
        url: URL
    ) {
        Task { @MainActor in
            logger.info("Cart link clicked", [
                "url": url.absoluteString
            ])

            if let delegate {
                delegate.storefrontWidgetDidClickLinkInCheckout(url: url)
            } else if UIApplication.shared.canOpenURL(url) {
                ParraLinkManager.shared.open(url: url)
            } else {
                logger.warn("Failed to open cart link", [
                    "url": url.absoluteString
                ])
            }
        }
    }

    nonisolated func checkoutDidEmitWebPixelEvent(
        event: ShopifyCheckoutSheetKit.PixelEvent
    ) {}
}
