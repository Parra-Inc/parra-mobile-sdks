//
//  ParraLoggerConfig.swift
//  ParraCore
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerConfig {
    public var printTimestamps: Bool
    public var printVerbosity: Bool
    public var printVerbositySymbol: Bool
    public var printThread: Bool
    public var printCallsite: Bool
    public var printModuleName: Bool
    public var printFileName: Bool
    public var logger: ParraLogger
    public var minimumAllowedLogLevel: ParraLogLevel = .default {
        didSet {
            ParraLogLevel.setMinAllowedLogLevel(minimumAllowedLogLevel)
        }
    }

    static let `default` = ParraLoggerConfig()

    init(
        printTimestamps: Bool = true,
        printVerbosity: Bool = true,
        printVerbositySymbol: Bool = true,
        printThread: Bool = false,
        printCallsite: Bool = false,
        printModuleName: Bool = true,
        printFileName: Bool = true,
        logger: ParraLogger = ParraDefaultLogger.default
    ) {
        self.printTimestamps = printTimestamps
        self.printVerbosity = printVerbosity
        self.printVerbositySymbol = printVerbositySymbol
        self.printThread = printThread
        self.printCallsite = printCallsite
        self.printModuleName = printModuleName
        self.printFileName = printFileName
        self.logger = logger

        ParraLogLevel.setMinAllowedLogLevel(minimumAllowedLogLevel)
    }

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
