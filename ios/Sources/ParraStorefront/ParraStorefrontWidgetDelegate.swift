//
//  ParraStorefrontWidgetDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 10/14/24.
//

import Parra
import SwiftUI

public protocol ParraStorefrontWidgetDelegate {
    nonisolated func storefrontWidgetViewProductDetails(
        product: ParraProduct,
        with variant: ParraProductVariant
    )

    nonisolated func storefrontWidgetAddedProductToCart(
        product: ParraProduct,
        with variant: ParraProductVariant,
        in quantity: Int
    )

    nonisolated func storefrontWidgetRemovedLineItemFromCart(
        lineItem: ParraCartLineItem,
        in quantity: Int
    )

    nonisolated func storefrontWidgetDidInitiateCheckout(
        lineItems: [ParraCartLineItem],
        with cost: ParraCartCost
    )

    nonisolated func storefrontWidgetDidCancelCheckout()

    nonisolated func storefrontWidgetDidFailCheckout(
        error: Error
    )

    nonisolated func storefrontWidgetShouldRecoverFromCheckoutError(
        error: Error
    ) -> Bool

    nonisolated func storefrontWidgetDidClickLinkInCheckout(
        url: URL
    )

    nonisolated func storefrontWidgetDidMakePurchase(
        orderDetails: ParraOrderDetails
    )
}
