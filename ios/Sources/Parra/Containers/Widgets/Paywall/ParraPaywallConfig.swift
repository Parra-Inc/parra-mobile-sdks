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
        visibleRelationships: Product.SubscriptionRelationship = .all,
        thankYouContent: ToastContent = .successDefault,
        purchaseErrorContent: ToastContent = .failureDefault,
        marketingContent: (() -> (any View))? = nil
    ) {
        self.visibleRelationships = visibleRelationships
        self.thankYouContent = thankYouContent
        self.purchaseErrorContent = purchaseErrorContent
        self.marketingContent = marketingContent
    }

    // MARK: - Public

    public struct ToastContent {
        // MARK: - Lifecycle

        public init(
            title: String,
            subtitle: String,
            icon: ParraImageContent? = nil,
            backgroundColor: Color? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.backgroundColor = backgroundColor
        }

        // MARK: - Public

        public static let successDefault = ToastContent(
            title: "Thank You",
            subtitle: "Your purchase has been received!",
            icon: .symbol("arrow.up.heart.fill")
        )

        public static let failureDefault = ToastContent(
            title: "Purchase error",
            subtitle: "Something went wrong completing this purchase. Please try again later.",
            icon: .symbol("creditcard.trianglebadge.exclamationmark")
        )

        public let title: String
        public let subtitle: String
        public let icon: ParraImageContent?
        public let backgroundColor: Color?
    }

    public static let `default` = ParraPaywallConfig()

    /// The kinds of subscription option relationships the view makes visible
    /// when someone is already subscribed to the subscription. This option is
    /// only relevant when your paywall is configured in the Parra dashboard
    /// to use a subscription Group ID and not a list of products.
    public let visibleRelationships: Product.SubscriptionRelationship

    public let thankYouContent: ToastContent
    public let purchaseErrorContent: ToastContent

    /// Overrides any marketing configuration provided by the Parra dashboard.
    public let marketingContent: (() -> (any View))?

    public static func registerDefaultConfig<Key>(
        _ config: ParraPaywallConfig,
        for key: Key
    ) where Key: RawRepresentable, Key.RawValue == String {
        registerDefaultConfig(config, for: key.rawValue)
    }

    public static func registerDefaultConfig(
        _ config: ParraPaywallConfig,
        for entitlement: String
    ) {
        defaultConfigs[entitlement] = config
    }

    public static func removeDefaultConfig<Key>(
        for key: Key
    ) where Key: RawRepresentable, Key.RawValue == String {
        removeDefaultConfig(for: key.rawValue)
    }

    public static func removeDefaultConfig(
        for entitlement: String
    ) {
        defaultConfigs.removeValue(forKey: entitlement)
    }

    public static func defaultConfig<Key>(
        for key: Key
    ) -> ParraPaywallConfig? where Key: RawRepresentable, Key.RawValue == String {
        return defaultConfig(for: key.rawValue)
    }

    public static func defaultConfig(
        for entitlement: String
    ) -> ParraPaywallConfig? {
        return defaultConfigs[entitlement]
    }

    // MARK: - Private

    private static var defaultConfigs: [String: ParraPaywallConfig] = [:]
}
