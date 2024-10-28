//
//  Storefront+createCartInputs.swift
//  Parra
//
//  Created by Mick MacCallum on 10/3/24.
//

import Buy
import Parra

extension Storefront.CartInput {
    static func createCartInput(
        productVariants: [(ParraProductVariant, UInt)] = [],
        as user: ParraUser?,
        discountCodes: [String] = [],
        attributes: [String: String]
    ) -> Storefront.CartInput {
        let linesInput = productVariants.map { variant, quantity in
            Storefront.CartLineInput.create(
                merchandiseId: .init(rawValue: variant.id),
                quantity: .value(Int32(quantity))
            )
        }

        let buyerIdentityInput = Storefront.CartBuyerIdentityInput.create(
            email: .value(user?.info.email),
            phone: .value(user?.info.phoneNumber)
        )

        let attributeInputs = attributes.map { key, value in
            Storefront.AttributeInput(
                key: key,
                value: value
            )
        }

        return Storefront.CartInput
            .create(
                attributes: .value(attributeInputs),
                lines: .value(linesInput),
                discountCodes: .value(discountCodes),
                buyerIdentity: .value(buyerIdentityInput)
            )
    }
}
