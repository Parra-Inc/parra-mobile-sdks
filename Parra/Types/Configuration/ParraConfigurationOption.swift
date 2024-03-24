//
//  ParraConfigurationOption.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraConfigurationOption: CaseIterable {
    /// Options to configure the Parra Logger. If no value is set here,
    /// you can still use the logger with its default options.
    case logger(ParraLoggerOptions)

    /// Whether or not Parra should register the device for push notifications.
    /// This in turn, will trigger the UIApplicationDelegate methods related
    /// to push permissions, and should be done if you intend to use
    /// `Parra.registerDevicePushToken(_:)`
    case pushNotifications(ParraPushNotificationOptions)

    /// The theme that will be used for an UI components rendered by Parra.
    case theme(ParraTheme)

    /// Global defaults to use for attributes for base Parra components. This
    /// allows for broad customization of how buttons/labels/etc look which will
    /// be built upon by builder factories for specific Widgets later.
    case globalComponentAttributes(GlobalComponentAttributes)

    case whatsNew(ParraWhatsNewOptions)

    // MARK: - Public

    public static var allCases: [ParraConfigurationOption] = [
        .logger(.default),
        .pushNotifications(.default),
        .theme(.default),
        .globalComponentAttributes(.default),
        .whatsNew(.default)
    ]
}
