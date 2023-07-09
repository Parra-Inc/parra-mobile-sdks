//
//  ParraLoggerOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerOptions {
    public enum Environment {
        public static let minimumLogLevelOverride = "PARRA_LOG_LEVEL"
    }

    public static let `default` = ParraLoggerOptions(
        environment: .automatic,
        minimumLogLevel: .info,
        consoleFormatOptions: [
            .printLevel(style: .default),
            .printTimestamps(style: .default),
            .printCallSite(options: .default),
            .printExtras
        ]
    )

    /// Use the environment option to override the behavior for when Parra
    /// logs are displayed in the console or uploaded to Parra. For more
    /// information, see ``ParraLoggerEnvironment``.
    public internal(set) var environment: ParraLoggerEnvironment

    /// Only logs at greater or equal severity will be kept.
    ///
    /// Order of precedance
    /// 1. Value of environmental variable `PARRA_LOG_LEVEL`.
    /// 2. The value specified by this option.
    /// 3. The default log level, `info`.
    public internal(set) var minimumLogLevel: ParraLogLevel

    /// For configurations where logs are output to the console instead of
    /// being uploaded to Parra, use these options to specify what information
    /// you'd like to be displayed.
    ///
    /// This includes whether or not to display data like timestamps, call site
    /// information, or categories. The order that options are passed to this
    /// array will be used to determine the order of their respective information
    /// in the output string.
    public internal(set) var consoleFormatOptions: [ParraLoggerConsoleFormatOption]
}
