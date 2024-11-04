//
//  ParraPushNotificationOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import UserNotifications

public struct ParraPushNotificationOptions: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(
        enabled: Bool = false,
        alerts: Bool = true,
        badges: Bool = true,
        sounds: Bool = true,
        provisional: Bool = false,
        promptTrigger: PromptTrigger = .manual,
        providesInAppNotificationSettings: Bool = true
    ) {
        self.enabled = enabled
        self.alerts = alerts
        self.badges = badges
        self.sounds = sounds
        self.provisional = provisional
        self.promptTrigger = promptTrigger
        self.providesInAppNotificationSettings = providesInAppNotificationSettings
    }

    // MARK: - Public

    public enum PromptTrigger {
        /// The default. Parra won't automatically prompt for push notification
        /// permission from your users. Access the `parra` environment value
        /// and call `parra.push.requestPushPermission()` to trigger the prompt.
        case manual
        case automatic
    }

    public static var `default` = ParraPushNotificationOptions()

    public static var allWithProvisional = ParraPushNotificationOptions(
        enabled: true,
        provisional: true
    )

    public static var allWithoutProvisional = ParraPushNotificationOptions(
        enabled: true,
        provisional: false
    )

    public let enabled: Bool
    public let alerts: Bool
    public let badges: Bool
    public let sounds: Bool
    public let provisional: Bool
    public let promptTrigger: PromptTrigger
    public let providesInAppNotificationSettings: Bool
}
