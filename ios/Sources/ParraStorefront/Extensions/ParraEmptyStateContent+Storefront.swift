//
//  ParraEmptyStateContent+Storefront.swift
//  Parra
//
//  Created by Mick MacCallum on 10/11/24.
//

import Parra

extension ParraEmptyStateContent {
    static let storefrontError = ParraEmptyStateContent(
        title: ParraLabelContent(text: "Something Went Wrong"),
        subtitle: ParraLabelContent(
            text: "An unexpected error occurred loading this store. Check back later!"
        ),
        icon: .symbol("network.slash", .monochrome),
        primaryAction: nil,
        secondaryAction: nil
    )

    static let storefrontProductMissing = ParraEmptyStateContent(
        title: ParraLabelContent(text: "Oops! We couldn't find that product."),
        subtitle: ParraLabelContent(
            text: "We couldn't find the product you're looking for. It may be out of stock or no longer available."
        ),
        icon: .symbol("tshirt", .monochrome),
        primaryAction: nil,
        secondaryAction: nil
    )
}
