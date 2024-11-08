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
            let orderDetails = ParraOrderDetails(
                orderDetails: event.orderDetails
            )

            StorefrontAnalytics.makePurchase(orderDetails)

            UIViewController.topMostViewController()?.dismiss(
                animated: true
            ) {
                self.delegate?.storefrontWidgetDidMakePurchase(
                    orderDetails: orderDetails
                )

                self.completeCheckout(with: orderDetails)
            }
        }
    }

    nonisolated func checkoutDidCancel() {
        Task { @MainActor in
            StorefrontAnalytics.cancelCheckout()

            UIViewController.topMostViewController()?.dismiss(
                animated: true
            ) {
                self.delegate?.storefrontWidgetDidCancelCheckout()
            }
        }
    }

    nonisolated func checkoutDidFail(
        error: ShopifyCheckoutSheetKit.CheckoutError
    ) {
        Task { @MainActor in

            switch error {
            case .checkoutExpired:
                logger.error(
                    "Cart has expired. Triggering refresh.",
                    error
                )

                refreshExpiredCart()
            default:
                let message: String = switch error {
                case .checkoutUnavailable(let message, _, let recoverable):
                    message
                case .configurationError(let message, _, let recoverable):
                    message
                case .sdkError(let underlying, let recoverable):
                    underlying.localizedDescription
                default:
                    "Unknown error"
                }

                logger.error("Checkout failed: \(message)", error)

                let fail = {
                    self.failCheckout(
                        with: message,
                        error: error,
                        isRecoverable: error.isRecoverable
                    )

                    self.delegate?.storefrontWidgetDidFailCheckout(
                        error: error
                    )
                }

                if error.isRecoverable {
                    fail()
                } else {
                    UIViewController.topMostViewController()?.dismiss(
                        animated: true
                    ) {
                        fail()
                    }
                }
            }
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
