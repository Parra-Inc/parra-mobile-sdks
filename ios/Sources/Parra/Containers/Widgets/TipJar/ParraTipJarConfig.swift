//
//  ParraTipJarConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI
import UIKit

public final class ParraTipJarConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        marketingContent: MarketingContentType = .default(.default),
        thankYouContent: ThankYouContent = .default,
        productViewStyle: ProductViewStyle = .compact,
        productsPreferPromotionalIcon: Bool = false,
        productIconBuilder: ((
            _ productId: String
        ) -> any View)? = nil
    ) {
        self.marketingContent = marketingContent
        self.thankYouContent = thankYouContent
        self.productViewStyle = productViewStyle
        self.productsPreferPromotionalIcon = productsPreferPromotionalIcon
        self.productIconBuilder = productIconBuilder
    }

    // MARK: - Public

    public enum ProductViewStyle: Hashable {
        case automatic
        case compact
        case large
        case regular
    }

    public struct ThankYouContent {
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

        public static let `default` = ThankYouContent(
            title: "Thank You",
            subtitle: "Your tip has been received. We appreciate your support!",
            icon: .symbol("arrow.up.heart.fill")
        )

        public let title: String
        public let subtitle: String
        public let icon: ParraImageContent?
        public let backgroundColor: Color?
    }

    public struct MarketingContent {
        // MARK: - Lifecycle

        public init(
            title: String,
            subtitle: String,
            icon: ParraImageContent? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
        }

        // MARK: - Public

        public static let `default` = MarketingContent(
            title: "Leave a Tip",
            subtitle: "Your donations help us keep the lights on and the content flowing.",
            icon: .symbol("heart.fill")
        )

        public let title: String
        public let subtitle: String
        public let icon: ParraImageContent?
    }

    public enum MarketingContentType {
        case custom(() -> any View)
        case `default`(MarketingContent)
    }

    public static let `default` = ParraTipJarConfig()

    public let marketingContent: MarketingContentType
    public let thankYouContent: ThankYouContent
    public let productViewStyle: ProductViewStyle
    public let productsPreferPromotionalIcon: Bool
    public let productIconBuilder: ((
        _ productId: String
    ) -> any View)?
}
