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
                title: "Backyarn Bundle",
                optionsNames: [],
                cost: .init(totalPrice: 110.00, subtotalPrice: 120.00),
                quantity: 1,
                quantityAvailable: 50,
                image: .init(
                    id: "backyardbundle",
                    url: URL(
                        string: "https://thedimelab.com/cdn/shop/files/71.heic?v=1724000610"
                    )!
                )
            ),
            .init(
                id: "2",
                variantId: "2-1",
                title: "Classic Football",
                optionsNames: ["Signed"],
                cost: .init(totalPrice: 50.00, subtotalPrice: 60.00),
                quantity: 4,
                quantityAvailable: 12,
                image: .init(
                    id: "classicfootball-signed",
                    url: URL(
                        string: "https://thedimelab.com/cdn/shop/files/71.heic?v=1724000610"
                    )!
                )
            ),
            .init(
                id: "3",
                variantId: "3-1",
                title: "Classic Football",
                optionsNames: ["Unsigned"],
                cost: .init(totalPrice: 110.00, subtotalPrice: 120.00),
                quantity: 2,
                quantityAvailable: 500,
                image: .init(
                    id: "classicfootball-signed",
                    url: URL(
                        string: "https://thedimelab.com/cdn/shop/files/71.heic?v=1724000610"
                    )!
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraCartLineItem] {
        return []
    }
}
