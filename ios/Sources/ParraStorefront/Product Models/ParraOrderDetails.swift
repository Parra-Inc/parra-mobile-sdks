//
//  ParraOrderDetails.swift
//  Parra
//
//  Created by Mick MacCallum on 10/14/24.
//

import ShopifyCheckoutSheetKit
import SwiftUI

public struct ParraOrderDetails {
    // MARK: - Lifecycle

    init(
        billingAddress: ParraOrderAddress?,
        cart: ParraOrderCartInfo,
        deliveries: [ParraOrderDeliveryInfo]?,
        email: String?,
        id: String,
        paymentMethods: [ParraOrderPaymentMethod]?,
        phone: String?
    ) {
        self.billingAddress = billingAddress
        self.cart = cart
        self.deliveries = deliveries
        self.email = email
        self.id = id
        self.paymentMethods = paymentMethods
        self.phone = phone
    }

    init(orderDetails: CheckoutCompletedEvent.OrderDetails) {
        self.billingAddress = ParraOrderAddress(orderDetails.billingAddress)
        self.cart = ParraOrderCartInfo(orderDetails.cart)
        self.deliveries = (orderDetails.deliveries ?? []).map {
            ParraOrderDeliveryInfo($0)
        }
        self.email = orderDetails.email
        self.id = orderDetails.id
        self.paymentMethods = (orderDetails.paymentMethods ?? []).map {
            ParraOrderPaymentMethod($0)
        }
        self.phone = orderDetails.phone
    }

    // MARK: - Public

    public let billingAddress: ParraOrderAddress?
    public let cart: ParraOrderCartInfo
    public let deliveries: [ParraOrderDeliveryInfo]?
    public let email: String?
    public let id: String
    public let paymentMethods: [ParraOrderPaymentMethod]?
    public let phone: String?
}

public struct ParraOrderAddress: Codable {
    // MARK: - Lifecycle

    init(
        address1: String?,
        address2: String?,
        city: String?,
        countryCode: String?,
        firstName: String?,
        lastName: String?,
        name: String?,
        phone: String?,
        postalCode: String?,
        referenceId: String?,
        zoneCode: String?
    ) {
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.countryCode = countryCode
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.phone = phone
        self.postalCode = postalCode
        self.referenceId = referenceId
        self.zoneCode = zoneCode
    }

    init?(_ address: CheckoutCompletedEvent.Address?) {
        guard let address else {
            return nil
        }

        self.address1 = address.address1
        self.address2 = address.address2
        self.city = address.city
        self.countryCode = address.countryCode
        self.firstName = address.firstName
        self.lastName = address.lastName
        self.name = address.name
        self.phone = address.phone
        self.postalCode = address.postalCode
        self.referenceId = address.referenceId
        self.zoneCode = address.zoneCode
    }

    // MARK: - Public

    public let address1: String?
    public let address2: String?
    public let city: String?
    public let countryCode: String?
    public let firstName: String?
    public let lastName: String?
    public let name: String?
    public let phone: String?
    public let postalCode: String?
    public let referenceId: String?
    public let zoneCode: String?
}

public struct ParraOrderCartInfo: Codable {
    // MARK: - Lifecycle

    init(
        lines: [ParraOrderCartLine],
        price: ParraOrderPrice,
        token: String
    ) {
        self.lines = lines
        self.price = price
        self.token = token
    }

    init(_ cartLineImage: CheckoutCompletedEvent.CartInfo) {
        self.token = cartLineImage.token
        self.price = ParraOrderPrice(cartLineImage.price)
        self.lines = cartLineImage.lines.map {
            ParraOrderCartLine($0)
        }
    }

    // MARK: - Public

    public let lines: [ParraOrderCartLine]
    public let price: ParraOrderPrice
    public let token: String
}

public struct ParraOrderCartLineImage: Codable {
    // MARK: - Lifecycle

    init(
        altText: String?,
        lg: String,
        md: String,
        sm: String
    ) {
        self.altText = altText
        self.lg = lg
        self.md = md
        self.sm = sm
    }

    init?(_ cartLineImage: CheckoutCompletedEvent.CartLineImage?) {
        guard let cartLineImage else {
            return nil
        }

        self.altText = cartLineImage.altText
        self.lg = cartLineImage.lg
        self.md = cartLineImage.md
        self.sm = cartLineImage.sm
    }

    // MARK: - Public

    public let altText: String?
    public let lg: String
    public let md: String
    public let sm: String
}

public struct ParraOrderCartLine: Codable {
    // MARK: - Lifecycle

    init(
        discounts: [ParraOrderDiscount]?,
        image: ParraOrderCartLineImage?,
        merchandiseId: String?,
        price: ParraOrderMoney,
        productId: String?,
        quantity: Int,
        title: String
    ) {
        self.discounts = discounts
        self.image = image
        self.merchandiseId = merchandiseId
        self.price = price
        self.productId = productId
        self.quantity = quantity
        self.title = title
    }

    init(_ cartLine: CheckoutCompletedEvent.CartLine) {
        self.discounts = (cartLine.discounts ?? []).map { ParraOrderDiscount($0) }
        self.image = ParraOrderCartLineImage(cartLine.image)
        self.merchandiseId = cartLine.merchandiseId
        self.price = ParraOrderMoney(cartLine.price)
        self.productId = cartLine.productId
        self.quantity = cartLine.quantity
        self.title = cartLine.title
    }

    // MARK: - Public

    public let discounts: [ParraOrderDiscount]?
    public let image: ParraOrderCartLineImage?
    public let merchandiseId: String?
    public let price: ParraOrderMoney
    public let productId: String?
    public let quantity: Int
    public let title: String
}

public struct ParraOrderDeliveryDetails: Codable {
    // MARK: - Lifecycle

    init(
        additionalInfo: String?,
        location: ParraOrderAddress?,
        name: String?
    ) {
        self.additionalInfo = additionalInfo
        self.location = location
        self.name = name
    }

    init(_ deliveryDetails: CheckoutCompletedEvent.DeliveryDetails) {
        self.additionalInfo = deliveryDetails.additionalInfo
        self.location = ParraOrderAddress(deliveryDetails.location)
        self.name = deliveryDetails.name
    }

    // MARK: - Public

    public let additionalInfo: String?
    public let location: ParraOrderAddress?
    public let name: String?
}

public struct ParraOrderDeliveryInfo: Codable {
    // MARK: - Lifecycle

    init(
        details: ParraOrderDeliveryDetails,
        method: String
    ) {
        self.details = details
        self.method = method
    }

    init(_ deliveryInfo: CheckoutCompletedEvent.DeliveryInfo) {
        self.details = ParraOrderDeliveryDetails(deliveryInfo.details)
        self.method = deliveryInfo.method
    }

    // MARK: - Public

    public let details: ParraOrderDeliveryDetails
    public let method: String
}

public struct ParraOrderDiscount: Codable {
    // MARK: - Lifecycle

    init(
        amount: ParraOrderMoney?,
        applicationType: String?,
        title: String?,
        value: Double?,
        valueType: String?
    ) {
        self.amount = amount
        self.applicationType = applicationType
        self.title = title
        self.value = value
        self.valueType = valueType
    }

    init(_ discount: CheckoutCompletedEvent.Discount) {
        self.amount = ParraOrderMoney(discount.amount)
        self.applicationType = discount.applicationType
        self.title = discount.title
        self.value = discount.value
        self.valueType = discount.valueType
    }

    // MARK: - Public

    public let amount: ParraOrderMoney?
    public let applicationType: String?
    public let title: String?
    public let value: Double?
    public let valueType: String?
}

public struct ParraOrderPaymentMethod: Codable {
    // MARK: - Lifecycle

    init(details: [String: String?], type: String) {
        self.details = details
        self.type = type
    }

    init(_ paymentMethod: CheckoutCompletedEvent.PaymentMethod) {
        self.details = paymentMethod.details
        self.type = paymentMethod.type
    }

    // MARK: - Public

    public let details: [String: String?]
    public let type: String
}

public struct ParraOrderPrice: Codable {
    // MARK: - Lifecycle

    init(
        discounts: [ParraOrderDiscount]?,
        shipping: ParraOrderMoney?,
        subtotal: ParraOrderMoney?,
        taxes: ParraOrderMoney?,
        total: ParraOrderMoney?
    ) {
        self.discounts = discounts
        self.shipping = shipping
        self.subtotal = subtotal
        self.taxes = taxes
        self.total = total
    }

    init(_ price: CheckoutCompletedEvent.Price) {
        self.total = ParraOrderMoney(price.total)
        self.taxes = ParraOrderMoney(price.taxes)
        self.subtotal = ParraOrderMoney(price.subtotal)
        self.shipping = ParraOrderMoney(price.shipping)
        self.discounts = (price.discounts ?? []).map { discount in
            ParraOrderDiscount(discount)
        }
    }

    // MARK: - Public

    public let discounts: [ParraOrderDiscount]?
    public let shipping: ParraOrderMoney?
    public let subtotal: ParraOrderMoney?
    public let taxes: ParraOrderMoney?
    public let total: ParraOrderMoney?
}

public struct ParraOrderMoney: Codable {
    // MARK: - Lifecycle

    init(amount: Double?, currencyCode: String?) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    init?(_ money: CheckoutCompletedEvent.Money?) {
        guard let money else {
            return nil
        }

        self.amount = money.amount
        self.currencyCode = money.currencyCode
    }

    init(_ money: CheckoutCompletedEvent.Money) {
        self.amount = money.amount
        self.currencyCode = money.currencyCode
    }

    // MARK: - Public

    public let amount: Double?
    public let currencyCode: String?
}
