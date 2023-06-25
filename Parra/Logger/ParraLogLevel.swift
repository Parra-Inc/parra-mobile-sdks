//
//  ParraLogLevel.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLogLevel: Int, Comparable {
    case trace  = 1
    case debug  = 2
    case info   = 4
    case warn   = 8
    case error  = 16
    case fatal  = 32

    internal static let `default` = ParraLogLevel.info

    public init?(name: String) {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "trace":
            self = .trace
        case "debug":
            self = .debug
        case "info":
            self = .info
        case "warn":
            self = .warn
        case "error":
            self = .error
        case "fatal":
            self = .fatal
        default:
            return nil
        }
    }

    public static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    internal private(set) static var minAllowedLogLevel: ParraLogLevel = .default

    internal static func setMinAllowedLogLevel(_ minLevel: ParraLogLevel) {
#if DEBUG
        if let rawLevelOverride = ProcessInfo.processInfo.environment[ParraLoggerConfig.Environment.allowedLogLevelOverrideKey],
           let level = ParraLogLevel(name: rawLevelOverride) {

            minAllowedLogLevel = level
        } else {
            minAllowedLogLevel = minLevel
        }
#else
        minAllowedLogLevel = minLevel
#endif
    }

    var isAllowed: Bool {
        return self >= ParraLogLevel.minAllowedLogLevel
    }

    var name: String {
        switch self {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warn:
            return "WARN"
        case .error:
            return "ERROR"
        case .fatal:
            return "FATAL"
        }
    }

    var symbol: String {
        switch self {
        case .trace:
            return "🟣"
        case .debug:
            return "🔵"
        case .info:
            return "⚪"
        case .warn:
            return "🟡"
        case .error:
            return "🔴"
        case .fatal:
            return "💀"
        }
    }
}
