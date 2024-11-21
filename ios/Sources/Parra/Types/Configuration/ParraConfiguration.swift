//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraConfiguration {
    // MARK: - Lifecycle

    public init(
        appInfoOptions: ParraAppInfoOptions = .default,
        globalComponentAttributes: ParraGlobalComponentAttributes = .default,
        launchScreenOptions: ParraLaunchScreen.Options? = nil,
        launchShortcutOptions: ParraLaunchShortcutOptions = .default,
        loggerOptions: ParraLoggerOptions = .default,
        pushNotificationOptions: ParraPushNotificationOptions = .default,
        theme: ParraTheme = .default,
        whatsNewOptions: ParraWhatsNewOptions = .default
    ) {
        self.appInfoOptions = appInfoOptions
        self.theme = theme
        self.globalComponentAttributes = globalComponentAttributes
        self.launchScreenOptions = ParraConfiguration.configureLaunchScreen(
            with: launchScreenOptions
        )
        self.launchShortcutOptions = launchShortcutOptions
        self.loggerOptions = ParraConfiguration.applyLoggerOptionsOverrides(
            loggerOptions: loggerOptions
        )
        self.pushNotificationOptions = pushNotificationOptions
        self.whatsNewOptions = whatsNewOptions
    }

    // MARK: - Public

    public static let `default` = ParraConfiguration()

    public let appInfoOptions: ParraAppInfoOptions
    public internal(set) var theme: ParraTheme
    public private(
        set
    ) var globalComponentAttributes: ParraGlobalComponentAttributes
    public let launchScreenOptions: ParraLaunchScreen.Options
    public let launchShortcutOptions: ParraLaunchShortcutOptions
    public let loggerOptions: ParraLoggerOptions
    public let pushNotificationOptions: ParraPushNotificationOptions
    public let whatsNewOptions: ParraWhatsNewOptions

    // MARK: - Private

    private static func configureLaunchScreen(
        with overrides: ParraLaunchScreen.Options?
    ) -> ParraLaunchScreen.Options {
        if let overrides {
            // If an override is provided, check its type. The default type
            // should only override Info.plist keys that are specified. Other
            // types should be used outright.

            if case .default(let config) = overrides.type {
                let finalConfig = ParraDefaultLaunchScreen.Config
                    .fromInfoDictionary(
                        in: config.bundle
                    )?.merging(overrides: config) ?? config

                return ParraLaunchScreen.Options(
                    type: .default(finalConfig),
                    fadeDuration: overrides.fadeDuration
                )
            } else {
                return overrides
            }
        }

        // If overrides are not provided, look for a default configuration in
        // the Info.plist, then look for a Storyboard configuration, then
        // finally use a default empty configuration.

        let bundle = Bundle.main // default
        let type: ParraLaunchScreenType = if let config = ParraDefaultLaunchScreen
            .Config.fromInfoDictionary(
                in: bundle
            )
        {
            .default(config)
        } else if let config = ParraStoryboardLaunchScreen.Config
            .fromInfoDictionary(in: bundle)
        {
            .storyboard(config)
        } else {
            .default(ParraDefaultLaunchScreen.Config())
        }

        return ParraLaunchScreen.Options(
            type: type,
            fadeDuration: ParraLaunchScreen.Options.defaultFadeDuration
        )
    }

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
        } else if ParraAppEnvironment.isParraDemoBeta {
            loggerOptions.minimumLogLevel = .debug
        }

        return loggerOptions
    }
}
