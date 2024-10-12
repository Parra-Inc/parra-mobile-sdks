//
//  ParraCartLineItem+ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Foundation
import Parra

extension ParraCartLineItem: ParraFixture {
    public static func validStates() -> [ParraCartLineItem] {
        return [
            .init(
                id: "1",
                variantId: "1-1",
                title: "Product Bundle",
                optionsNames: [],
                cost: .init(totalPrice: 110.00, subtotalPrice: 120.00),
                quantity: 1,
                quantityAvailable: 50,
                image: .init(
                    id: "backyardbundle",
                    url: URL(
                        string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                    )!
                )
            ),
            .init(
                id: "2",
                variantId: "2-1",
                title: "Classic Product",
                optionsNames: ["Signed"],
                cost: .init(totalPrice: 50.00, subtotalPrice: 60.00),
                quantity: 4,
                quantityAvailable: 12,
                image: .init(
                    id: "classic-product-signed",
                    url: URL(
                        string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                    )!
                )
            ),
            .init(
                id: "3",
                variantId: "3-1",
                title: "Classic Product",
                optionsNames: ["Unsigned"],
                cost: .init(totalPrice: 110.00, subtotalPrice: 120.00),
                quantity: 2,
                quantityAvailable: 500,
                image: .init(
                    id: "classic-product-signed",
                    url: URL(
                        string: "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?v=1530129081"
                    )!
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraCartLineItem] {
        return []
    }
}
