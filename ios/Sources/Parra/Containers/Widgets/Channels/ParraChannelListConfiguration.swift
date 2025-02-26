//
//  ParraChannelListConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/25.
//

import SwiftUI

public final class ParraChannelListConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        navigationTitle: String = "Messages",
        defaultChannelConfig: ParraChannelConfiguration = .default,
        emptyStateContent: ParraEmptyStateContent = ParraChannelListConfiguration
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraChannelListConfiguration
            .defaultErrorStateContent
    ) {
        self.defaultChannelConfig = defaultChannelConfig
        self.navigationTitle = navigationTitle
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraChannelListConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "No Conversations Yet"
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load any conversations. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    /// The config that will be passed to individual channels when the user
    /// navigates to them from the list.
    public let defaultChannelConfig: ParraChannelConfiguration

    public let navigationTitle: String

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
