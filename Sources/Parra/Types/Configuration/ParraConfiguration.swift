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
        themeOptions: ParraTheme = .default,
        globalComponentAttributes: ParraGlobalComponentAttributes = .default,
        loggerOptions: ParraLoggerOptions = .default,
        pushNotificationOptions: ParraPushNotificationOptions = .default,
        whatsNewOptions: ParraReleaseOptions = .default
    ) {
        self.appInfoOptions = appInfoOptions
        self.theme = themeOptions
        self.globalComponentAttributes = globalComponentAttributes
        self.loggerOptions = ParraConfiguration.applyLoggerOptionsOverrides(
            loggerOptions: loggerOptions
        )
        self.pushNotificationOptions = pushNotificationOptions
        self.whatsNewOptions = whatsNewOptions
    }

    // MARK: - Public

    public let appInfoOptions: ParraAppInfoOptions
    public internal(set) var theme: ParraTheme
    public private(
        set
    ) var globalComponentAttributes: ParraGlobalComponentAttributes
    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationOptions: ParraPushNotificationOptions
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
