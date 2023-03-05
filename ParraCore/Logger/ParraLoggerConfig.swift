//
//  ParraLoggerConfig.swift
//  ParraCore
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerConfig {
    public var printTimestamps = true
    public var printVerbosity = true
    public var printVerbositySymbol = true
    public var printThread = false
    public var printCallsite = false
    public var printModuleName = true
    public var logger: ParraLogger = ParraDefaultLogger.default
    public var minimumAllowedLogLevel: ParraLogLevel = .info

    static let `default` = ParraLoggerConfig()

    enum Constant {
        static let logEventPrefix = "parra:logger:"
        static let logEventMessageKey = "\(logEventPrefix)message"
        static let logEventLevelKey = "\(logEventPrefix)level"
        static let logEventTimestampKey = "\(logEventPrefix)timestamp"
        static let logEventFileKey = "\(logEventPrefix)file"
        static let logEventModuleKey = "\(logEventPrefix)module"
        static let logEventThreadKey = "\(logEventPrefix)thread"
        static let logEventExtraKey = "\(logEventPrefix)extra"
        static let logEventCallStackKey = "\(logEventPrefix)stack"
    }

    enum Environment {
        static let allowedLogLevelOverrideKey = "PARRA_LOG_LEVEL"
    }
}
