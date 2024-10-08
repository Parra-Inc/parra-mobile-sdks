//
//  Storefront+createCartInputs.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 10/3/24.
//

import Buy
import Parra

extension Storefront.CartInput {
    static func createCartInput(
        productVariants: [(ParraProductVariant, UInt)] = [],
        as user: ParraUser?
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

        return Storefront.CartInput.create(
            lines: .value(linesInput),
            buyerIdentity: .value(buyerIdentityInput)
        )
    }
}
