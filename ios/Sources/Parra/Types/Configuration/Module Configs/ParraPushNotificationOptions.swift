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
        openSettingsHandler: ((_ notification: UNNotification?) -> Void)? = nil
    ) {
        self.enabled = enabled
        self.alerts = alerts
        self.badges = badges
        self.sounds = sounds
        self.provisional = provisional
        self.openSettingsHandler = openSettingsHandler
    }

    // MARK: - Public

    public static var `default` = ParraPushNotificationOptions()
    public static var allWithProvisional = ParraPushNotificationOptions(
        enabled: true,
        alerts: true,
        badges: true,
        sounds: true,
        provisional: true
    )
    public static var allWithoutProvisional = ParraPushNotificationOptions(
        enabled: true,
        alerts: true,
        badges: true,
        sounds: true,
        provisional: false
    )

    public let enabled: Bool
    public let alerts: Bool
    public let badges: Bool
    public let sounds: Bool
    public let provisional: Bool
    public let openSettingsHandler: ((_ notification: UNNotification?) -> Void)?
}
