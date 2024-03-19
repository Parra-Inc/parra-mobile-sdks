//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraConfiguration {
    // MARK: - Lifecycle

    init(
        loggerOptions: ParraLoggerOptions,
        pushNotificationsEnabled: Bool,
        theme: ParraTheme,
        globalComponentAttributes: GlobalComponentAttributes,
        whatsNewOptions: ParraWhatsNewOptions
    ) {
        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.theme = theme
        self.globalComponentAttributes = globalComponentAttributes
        self.whatsNewOptions = whatsNewOptions
    }

    init(options: [ParraConfigurationOption]) {
        var loggerOptions = ParraConfiguration.default.loggerOptions
        var pushNotificationsEnabled = ParraConfiguration.default
            .pushNotificationsEnabled
        var theme = ParraTheme.default
        var globalComponentAttributes = GlobalComponentAttributes()
        var whatsNewOptions = ParraWhatsNewOptions.default

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
            case .whatsNew(let whatsNew):
                whatsNewOptions = whatsNew
            }
        }

        self.loggerOptions = loggerOptions
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.theme = theme
        self.globalComponentAttributes = globalComponentAttributes
        self.whatsNewOptions = whatsNewOptions
    }

    // MARK: - Public

    public static let `default`: ParraConfiguration = .init(
        loggerOptions: applyLoggerOptionsOverrides(
            loggerOptions: .default
        ),
        pushNotificationsEnabled: false,
        theme: .default,
        globalComponentAttributes: GlobalComponentAttributes(),
        whatsNewOptions: .default
    )

    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationsEnabled: Bool
    public internal(set) var theme: ParraTheme
    public private(set) var globalComponentAttributes: GlobalComponentAttributes
    public let whatsNewOptions: ParraWhatsNewOptions

    // MARK: - Internal

    private(set) static var current: ParraConfiguration = .default

    // MARK: - Private

    private static func applyLoggerOptionsOverrides(
        loggerOptions initialOptions: ParraLoggerOptions
    ) -> ParraLoggerOptions {
        var loggerOptions = initialOptions

        let envVar = ParraLoggerOptions.Environment.minimumLogLevelOverride
        if let rawLevelOverride = ProcessInfo.processInfo.environment[envVar],
           let level = ParraLogLevel(name: rawLevelOverride)
        {
            Logger.info(
                "\(envVar) is set. Changing minimum log level from \(initialOptions.minimumLogLevel.name) to \(level.name)"
            )

            loggerOptions.minimumLogLevel = level
        }

        return loggerOptions
    }
}
