//
//  ParraOrderDetails+ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 11/7/24.
//

import Parra
import SwiftUI

private let productImageUrl =
    "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"

// MARK: - ParraOrderDetails + ParraFixture

extension ParraOrderDetails: ParraFixture {
    public static func validStates() -> [ParraOrderDetails] {
        return [
            ParraOrderDetails(
                billingAddress: ParraOrderAddress(
                    address1: "1234 Main St",
                    address2: nil,
                    city: "Miami",
                    countryCode: "United States",
                    firstName: "Mick",
                    lastName: "MacCallum",
                    name: "Mick M.",
                    phone: "239-867-5309",
                    postalCode: "99221",
                    referenceId: .uuid,
                    zoneCode: nil
                ),
                cart: ParraOrderCartInfo(
                    lines: [
                        ParraOrderCartLine(
                            discounts: [],
                            image: ParraOrderCartLineImage(
                                altText: "A photo of my product",
                                lg: productImageUrl,
                                md: productImageUrl,
                                sm: productImageUrl
                            ),
                            merchandiseId: .uuid,
                            price: ParraOrderMoney(
                                amount: 120.99,
                                currencyCode: "USD"
                            ),
                            productId: "product-1",
                            quantity: 3,
                            title: "Cool product"
                        ),
                        ParraOrderCartLine(
                            discounts: [],
                            image: ParraOrderCartLineImage(
                                altText: "A photo of my product",
                                lg: productImageUrl,
                                md: productImageUrl,
                                sm: productImageUrl
                            ),
                            merchandiseId: .uuid,
                            price: ParraOrderMoney(
                                amount: 120.99,
                                currencyCode: "USD"
                            ),
                            productId: "product-1",
                            quantity: 1,
                            title: "Cool product with a medium length description"
                        ),
                        ParraOrderCartLine(
                            discounts: [],
                            image: ParraOrderCartLineImage(
                                altText: "A photo of my product",
                                lg: productImageUrl,
                                md: productImageUrl,
                                sm: productImageUrl
                            ),
                            merchandiseId: .uuid,
                            price: ParraOrderMoney(
                                amount: 120.99,
                                currencyCode: "USD"
                            ),
                            productId: "product-1",
                            quantity: 5,
                            title: "Cool product with a description that is actually unreasonably long and will wrap around the screen"
                        )
                    ],
                    price: ParraOrderPrice(
                        discounts: [
                            ParraOrderDiscount(
                                amount: ParraOrderMoney(
                                    amount: 10.0,
                                    currencyCode: "USD"
                                ),
                                applicationType: "automatic",
                                title: "Bulk deal",
                                value: nil,
                                valueType: nil
                            )
                        ],
                        shipping: ParraOrderMoney(
                            amount: 15.00,
                            currencyCode: "USD"
                        ),
                        subtotal: ParraOrderMoney(
                            amount: 360,
                            currencyCode: "USD"
                        ),
                        taxes: ParraOrderMoney(
                            amount: 25.0,
                            currencyCode: "USD"
                        ),
                        total: ParraOrderMoney(
                            amount: 400.0,
                            currencyCode: "USD"
                        )
                    ),
                    token: .uuid
                ),
                deliveries: [
                    ParraOrderDeliveryInfo(
                        details: ParraOrderDeliveryDetails(
                            additionalInfo: "Leave by mailbox",
                            location: ParraOrderAddress(
                                address1: "1234 Main St",
                                address2: nil,
                                city: "Miami",
                                countryCode: "United States",
                                firstName: "Mick",
                                lastName: "MacCallum",
                                name: "Mick M.",
                                phone: "239-867-5309",
                                postalCode: "99221",
                                referenceId: .uuid,
                                zoneCode: nil
                            ),
                            name: "Mick's house"
                        ),
                        method: "UPS Ground"
                    )
                ],
                email: "testing@parra.io",
                id: .uuid,
                paymentMethods: [
                    ParraOrderPaymentMethod(
                        details: [
                            "payment_method_name": "Visa",
                            "name": "Mick MacCallum",
                            "number": "**** **** **** 1234",
                            "expiration_month": "12",
                            "expiration_year": "2"
                        ],
                        type: "VISA"
                    )
                ],
                phone: "239-867-5309"
            )
        ]
    }

    public static func invalidStates() -> [ParraOrderDetails] {
        return []
    }
}
