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
        self.notificationSettingsConfig = nil
    }

    public init(
        emptyStateContent: ParraEmptyStateContent,
        errorStateContent: ParraEmptyStateContent
    ) {
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
        self.notificationSettingsConfig = nil
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

    // MARK: - Internal

    /// This will only be used internally and its presence indicates that the
    /// settings view is the managed notification settings view.
    var notificationSettingsConfig: ParraUserNotificationSettingsConfiguration?
}
