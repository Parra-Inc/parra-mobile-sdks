//
//  ParraChannelConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

public final class ParraChannelConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        paywallConfig: ParraPaywallConfig? = nil,
        emptyStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultErrorStateContent
    ) {
        self.paywallConfig = paywallConfig
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraChannelConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "Nothing here yet"
        ),
        subtitle: ParraLabelContent(
            text: "Check back later for new content!"
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load content feed. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
    public let paywallConfig: ParraPaywallConfig?
}
