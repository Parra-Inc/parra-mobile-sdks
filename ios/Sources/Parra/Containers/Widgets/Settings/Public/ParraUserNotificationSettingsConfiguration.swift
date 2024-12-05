//
//  ParraUserNotificationSettingsConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 12/4/24.
//

import Foundation

//

public final class ParraUserNotificationSettingsConfiguration: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        notDeterminedStatusInfo: PermissionInfo = .notDeterminedDefault,
        provisionalStatusInfo: PermissionInfo = .provisionalDefault,
        deniedStatusInfo: PermissionInfo = .deniedDefault,
        emptyStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultEmptyStateContent,
        errorStateContent: ParraEmptyStateContent = ParraFeedConfiguration
            .defaultErrorStateContent
    ) {
        self.notDeterminedStatusInfo = notDeterminedStatusInfo
        self.provisionalStatusInfo = provisionalStatusInfo
        self.deniedStatusInfo = deniedStatusInfo
        self.emptyStateContent = emptyStateContent
        self.errorStateContent = errorStateContent
    }

    // MARK: - Public

    public struct PermissionInfo {
        // MARK: - Lifecycle

        public init(
            title: String,
            description: String,
            actionTitle: String
        ) {
            self.title = title
            self.description = description
            self.actionTitle = actionTitle
        }

        // MARK: - Public

        public static let notDeterminedDefault = PermissionInfo(
            title: "Enable notifications",
            description: "Notifications are currently disabled. Turn them on to stay informed about important updates.",
            actionTitle: "Enable notifications"
        )

        public static let provisionalDefault = PermissionInfo(
            title: "Enable notifications",
            description: "Turn on notifications to stay informed about important updates.",
            actionTitle: "Enable notifications"
        )

        public static let deniedDefault = PermissionInfo(
            title: "Push permissions denied",
            description: "You're not receiving push notifications. You can enable them in your device's settings.",
            actionTitle: "Open settings"
        )

        public let title: String
        public let description: String
        public let actionTitle: String
    }

    public static let `default` = ParraUserNotificationSettingsConfiguration()

    public static let defaultEmptyStateContent = ParraEmptyStateContent(
        title: ParraLabelContent(
            text: "No notification settings available"
        ),
        subtitle: ParraLabelContent(
            text: "This settings view is empty."
        )
    )

    public static let defaultErrorStateContent = ParraEmptyStateContent(
        title: ParraEmptyStateContent.errorGeneric.title,
        subtitle: ParraLabelContent(
            text: "Failed to load notification settings. Please try again later."
        ),
        icon: .symbol("network.slash", .monochrome)
    )

    public let notDeterminedStatusInfo: PermissionInfo
    public let provisionalStatusInfo: PermissionInfo
    public let deniedStatusInfo: PermissionInfo

    public let emptyStateContent: ParraEmptyStateContent
    public let errorStateContent: ParraEmptyStateContent
}
