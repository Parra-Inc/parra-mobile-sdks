//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraConfiguration {
    public let loggerConfig: ParraLoggerConfig
    public let pushNotificationsEnabled: Bool

    public internal(set) var tenantId: String?
    public internal(set) var applicationId: String?

    internal init(
        loggerConfig: ParraLoggerConfig,
        pushNotificationsEnabled: Bool
    ) {
        self.loggerConfig = loggerConfig
        self.pushNotificationsEnabled = pushNotificationsEnabled

        self.tenantId = nil
        self.applicationId = nil
    }

    internal init(options: [ParraConfigurationOption]) {
        var loggerConfig = ParraConfiguration.default.loggerConfig
        var pushNotificationsEnabled = ParraConfiguration.default.pushNotificationsEnabled

        for option in options {
            switch option {
            case .logger(let parraLoggerConfig):
                loggerConfig = parraLoggerConfig
            case .pushNotifications:
                pushNotificationsEnabled = true
            }
        }

        self.loggerConfig = loggerConfig
        self.pushNotificationsEnabled = pushNotificationsEnabled
    }

    public static let `default` = ParraConfiguration(
        loggerConfig: .default,
        pushNotificationsEnabled: false
    )

    internal mutating func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }

    internal mutating func setApplicationId(_ applicationId: String?) {
        self.applicationId = applicationId
    }
}
