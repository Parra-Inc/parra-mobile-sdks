//
//  ParraPaywallConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

public final class ParraPaywallConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        defaultTitle: String = "Premium Membership",
        defaultSubtitle: String =
            "Start a subscription to our premium membership to access this premium content.",
        visibleRelationships: Product.SubscriptionRelationship = .all
    ) {
        self.defaultTitle = defaultTitle
        self.defaultSubtitle = defaultSubtitle
        self.visibleRelationships = visibleRelationships
    }

    // MARK: - Public

    public static let `default` = ParraPaywallConfig()

    public let defaultTitle: String
    public let defaultSubtitle: String

    /// The kinds of subscription option relationships the view makes visible
    /// when someone is already subscribed to the subscription. This option is
    /// only relevant when your paywall is configured in the Parra dashboard
    /// to use a subscription Group ID and not a list of products.
    public let visibleRelationships: Product.SubscriptionRelationship
}
