//
//  ParraConfigurationOption.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraConfigurationOption {
    /// Options to configure the Parra Logger. If no value is set here,
    /// you can still use the logger with its default options.
    case logger(options: ParraLoggerOptions)

    /// Whether or not Parra should register the device for push notifications.
    /// This in turn, will trigger the UIApplicationDelegate methods related
    /// to push permissions, and should be done if you intend to use
    /// `Parra.registerDevicePushToken(_:)`
    case pushNotifications

    /// The theme that will be used for an UI components rendered by Parra.
    case theme(_ theme: ParraTheme)

    /// Global defaults to use for attributes for base Parra components. This
    /// allows for broad customization of how buttons/labels/etc look which will
    /// be built upon by builder factories for specific Widgets later.
    case globalComponentAttributes(
        _ globalComponentAttributes: GlobalComponentAttributes
    )

    case whatsNew(ParraWhatsNewOptions)
}
