//
//  ParraStorefrontError.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Foundation

public enum ParraStorefrontError: Error {
    case failedToLoadProducts
    case failedToCreateCart
    case failedToInitiateCheckout
    case failedToAddProductToCart(ParraProductVariant)
    case failedToUpdateNote(String?)
    case failedToUpdateQuantity(ParraCartLineItem)
    case failedToRemoveItemFromCart(ParraCartLineItem)
    case cartNotReady
    case quantityOutOfRange
    case failedToBuyItNow(ParraProductVariant)
    case unknown(Error?)
}
