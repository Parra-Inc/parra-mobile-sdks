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

    public init(
        appInfoOptions: ParraAppInfoOptions = .default,
        globalComponentAttributes: GlobalComponentAttributes = .default,
        loggerOptions: ParraLoggerOptions = .default,
        pushNotificationOptions: ParraPushNotificationOptions = .default,
        themeOptions: ParraTheme = .default,
        whatsNewOptions: ParraReleaseOptions = .default
    ) {
        self.appInfoOptions = appInfoOptions
        self.globalComponentAttributes = globalComponentAttributes
        self.pushNotificationOptions = pushNotificationOptions
        self.theme = themeOptions
        self.whatsNewOptions = whatsNewOptions

        self.loggerOptions = ParraConfiguration.applyLoggerOptionsOverrides(
            loggerOptions: loggerOptions
        )
    }

    // MARK: - Public

    public let appInfoOptions: ParraAppInfoOptions
    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationOptions: ParraPushNotificationOptions
    public internal(set) var theme: ParraTheme
    public private(set) var globalComponentAttributes: GlobalComponentAttributes
    public let whatsNewOptions: ParraReleaseOptions

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
        } else if AppEnvironment.isParraDemoBeta {
            loggerOptions.minimumLogLevel = .debug
        }

        return loggerOptions
    }
}
