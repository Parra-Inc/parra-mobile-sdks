//
//  ParraUserSettingsConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

public final class ParraUserSettingsConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init() {
        self.emptyStateContent = ParraFeedConfiguration.defaultEmptyStateContent
        self.errorStateContent = ParraFeedConfiguration.defaultErrorStateContent
    }

    public init(
        emptyStateContent: ParraEmptyStateContent,
        errorStateContent: ParraEmptyStateContent
    ) {
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public static let `default` = ParraUserSettingsConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "No settings available"
        ),
        subtitle: ParraLabelContent(
            text: "This settings view is empty."
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load settings. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
