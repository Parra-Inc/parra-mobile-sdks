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
}
