//
//  StorefrontAnalytics.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import Buy
import Foundation
import Parra
import ShopifyCheckoutSheetKit

@MainActor
final class StorefrontAnalytics {
    static func viewProductDetails(
        _ product: ParraProduct,
        _ variant: ParraProductVariant
    ) {
        let params: [String: Any] = [
            "product_id": product.id,
            "product_name": product.name,
            "variant_id": variant.id,
            "variant_name": variant.title
        ]

        Parra.logEvent(.view(element: "product_details"), params)
    }

    static func addProductToCart(
        _ product: ParraProduct,
        _ variant: ParraProductVariant,
        _ quantity: UInt
    ) {
        let params: [String: Any] = [
            "product_id": product.id,
            "product_name": product.name,
            "variant_id": variant.id,
            "variant_name": variant.title,
            "quantity": quantity
        ]

        Parra.logEvent(.tap(element: "add_to_cart"), params)
    }

    static func removeItemFromCart(
        _ item: ParraCartLineItem,
        _ quantity: UInt
    ) {
        let params: [String: Any] = [
            "product_name": item.title,
            "variant_id": item.variantId,
            "quantity": quantity
        ]

        Parra.logEvent(.tap(element: "remove_from_cart"), params)
    }

    static func initiateCheckout(
        _ lineItems: [ParraCartLineItem],
        _ cost: ParraCartCost
    ) {
        var checkoutParams: [String: Any] = [
            "currency": cost.totalPrice.currencyCode,
            "value": NSDecimalNumber(
                decimal: cost.totalPrice.amount
            ).doubleValue
        ]

        checkoutParams["items"] = lineItems.map { line in
            return [
                "quantity": line.quantity,
                "item_name": line.title,
                "variant_id": line.variantId,
                "currency": line.cost.amountPerQuantity.currencyCode,
                "value": NSDecimalNumber(
                    decimal: line.cost.totalPrice.amount
                ).doubleValue
            ]
        }

        Parra.logEvent(.tap(element: "begin_checkout"), checkoutParams)
    }

    static func cancelCheckout() {
        Parra.logEvent(.tap(element: "cancel_checkout"))
    }

    static func makePurchase(
        _ lineItems: [CheckoutCompletedEvent.CartLine]
    ) {
        for line in lineItems {
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
    }
}
