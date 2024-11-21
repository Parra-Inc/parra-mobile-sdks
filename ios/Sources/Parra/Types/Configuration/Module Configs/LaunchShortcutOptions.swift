//
//  LaunchShortcutOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 11/21/24.
//

import UIKit

public struct ParraLaunchShortcutOptions: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    /// - Parameters:
    ///   - enabled: Whether or not Parra's shortcut items should be
    ///   automatically added and enabled.
    ///   - shortcutItems: The list of shortcut items that Parra will add to
    ///   your app. This is overridable in case you want to provide a subset of
    ///   these items or make modifications.
    ///   - feedbackFormId: The ID of the feedback form that should be presented
    ///   when the `defaultFeedbackShortcutItem` item is used. If unset, this
    ///   will be the default form ID from application info.
    public init(
        enabled: Bool = true,
        shortcutItems: [UIApplicationShortcutItem] = ParraLaunchShortcutOptions
            .defaultShortcutItems,
        feedbackFormId: String? = nil
    ) {
        self.enabled = enabled
        self.shortcutItems = shortcutItems
        self.feedbackFormId = feedbackFormId
    }

    // MARK: - Public

    public static var `default` = ParraLaunchShortcutOptions()

    public static let defaultShortcutItems = [
        ParraLaunchShortcutOptions.defaultFeedbackShortcutItem
    ]

    public static let defaultFeedbackShortcutItem = UIApplicationShortcutItem(
        type: LaunchShortcutManager.Constants.feedbackShortcutId,
        localizedTitle: "Something wrong?",
        localizedSubtitle: "Please leave us feedback before deleting!",
        icon: UIApplicationShortcutIcon(
            systemImageName: "heart.fill"
        )
    )

    public let enabled: Bool
    public let shortcutItems: [UIApplicationShortcutItem]
    public let feedbackFormId: String?
}
