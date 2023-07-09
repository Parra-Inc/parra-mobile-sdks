//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraConfiguration {
    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationsEnabled: Bool

    public internal(set) var tenantId: String?
    public internal(set) var applicationId: String?

    internal init(
        loggerOptions: ParraLoggerOptions,
        pushNotificationsEnabled: Bool
    ) {
        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled

        self.tenantId = nil
        self.applicationId = nil
    }

    internal init(options: [ParraConfigurationOption]) {
        var loggerOptions = ParraConfiguration.default.loggerOptions
        var pushNotificationsEnabled = ParraConfiguration.default.pushNotificationsEnabled

        for option in options {
            switch option {
            case .logger(let logOptions):
                loggerOptions = ParraConfiguration.applyLoggerOptionsOverrides(
                    loggerOptions: logOptions
                )
            case .pushNotifications:
                pushNotificationsEnabled = true
            }
        }

        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled
    }

    public static let `default`: ParraConfiguration = {
        return ParraConfiguration(
            loggerOptions: applyLoggerOptionsOverrides(
                loggerOptions: .default
            ),
            pushNotificationsEnabled: false
        )
    }()

    internal mutating func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }

    internal mutating func setApplicationId(_ applicationId: String?) {
        self.applicationId = applicationId
    }

    private static func applyLoggerOptionsOverrides(
        loggerOptions initialOptions: ParraLoggerOptions
    ) -> ParraLoggerOptions {
        var loggerOptions = initialOptions

        let envVar = ParraLoggerOptions.Environment.minimumLogLevelOverride
        if let rawLevelOverride = ProcessInfo.processInfo.environment[envVar],
            let level = ParraLogLevel(name: rawLevelOverride) {

            Logger.info(
                "\(envVar) is set. Changing minimum log level from \(initialOptions.minimumLogLevel.name) to \(level.name)"
            )

            loggerOptions.minimumLogLevel = level
        }

        return loggerOptions
    }
}
