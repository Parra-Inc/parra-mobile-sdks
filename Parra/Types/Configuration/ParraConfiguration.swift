//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

/// Only static configuration that doesn't change after app initialization.
public struct ParraConfiguration {
    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationsEnabled: Bool
    public internal(set) var theme: ParraTheme
    public private(set) var globalComponentAttributes: GlobalComponentAttributes

    internal private(set) static var current: ParraConfiguration = .default

    internal init(
        loggerOptions: ParraLoggerOptions,
        pushNotificationsEnabled: Bool,
        theme: ParraTheme,
        globalComponentAttributes: GlobalComponentAttributes
    ) {
        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.theme = theme
        self.globalComponentAttributes = globalComponentAttributes
    }

    internal init(options: [ParraConfigurationOption]) {
        var loggerOptions = ParraConfiguration.default.loggerOptions
        var pushNotificationsEnabled = ParraConfiguration.default.pushNotificationsEnabled
        var theme = ParraTheme.default
        var globalComponentAttributes = GlobalComponentAttributes()

        for option in options {
            switch option {
            case .logger(let logOptions):
                loggerOptions = ParraConfiguration.applyLoggerOptionsOverrides(
                    loggerOptions: logOptions
                )
            case .pushNotifications:
                pushNotificationsEnabled = true
            case .theme(let userTheme):
                theme = userTheme
            case .globalComponentAttributes(let attributes):
                globalComponentAttributes = attributes
            }
        }

        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.theme = theme
        self.globalComponentAttributes = globalComponentAttributes
    }

    public static let `default`: ParraConfiguration = {
        return ParraConfiguration(
            loggerOptions: applyLoggerOptionsOverrides(
                loggerOptions: .default
            ),
            pushNotificationsEnabled: false,
            theme: .default,
            globalComponentAttributes: GlobalComponentAttributes()
        )
    }()

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
