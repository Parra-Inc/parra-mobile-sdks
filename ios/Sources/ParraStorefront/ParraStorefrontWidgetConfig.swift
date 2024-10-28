//
//  ParraStorefrontWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation
import Parra

public final class ParraStorefrontWidgetConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        navigationTitle: String = "Products",
        showDismissButton: Bool = false,
        checkoutAttributes: [String: String] = [:],
        checkoutDiscountCodes: [String] = [],
        emptyStateContent: ParraEmptyStateContent = ParraStorefrontWidgetConfig
            .defaultEmptyStateContent,
        productNotFoundContent: ParraEmptyStateContent = ParraStorefrontWidgetConfig
            .defaultProductNotFoundContent,
        errorStateContent: ParraEmptyStateContent = ParraStorefrontWidgetConfig
            .defaultErrorStateContent

    ) {
        self.navigationTitle = navigationTitle
        self.showDismissButton = showDismissButton
        self.checkoutAttributes = checkoutAttributes
        self.checkoutDiscountCodes = checkoutDiscountCodes
        self.emptyStateContent = emptyStateContent
        self.productNotFoundContent = productNotFoundContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraStorefrontWidgetConfig()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Nothing here yet"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later for new products!"
        )
    )

    public static let defaultProductNotFoundContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Oops! We couldn't find that product."
        ),
        subtitle: ParraLabelContent(
            text: "We couldn't find the product you're looking for. It may be out of stock or no longer available."
        ),
        icon: .symbol("tshirt", .monochrome)
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load products. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let navigationTitle: String
    public let showDismissButton: Bool

    public let checkoutAttributes: [String: String]
    public let checkoutDiscountCodes: [String]

    public let emptyStateContent: ParraEmptyStateContent
    public let productNotFoundContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
