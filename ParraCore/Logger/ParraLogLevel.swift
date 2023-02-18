//
//  ParraLogLevel.swift
//  ParraCore
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLogLevel: Int, Comparable {
    public static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case trace  = 1
    case debug  = 2
    case info   = 4
    case warn   = 8
    case error  = 16
    case fatal  = 32

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

    private static var minAllowedLogLevel: ParraLogLevel = {
        if let rawLevelOverride = ProcessInfo.processInfo.environment[ParraLoggerConfig.Environment.allowedLogLevelOverrideKey],
           let level = ParraLogLevel(name: rawLevelOverride) {

            return level
        }

        return .warn
    }()

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

    var outputName: String {
        switch self {
        case .trace:
            return "🟣 \(name)"
        case .debug:
            return "🔵 \(name)"
        case .info:
            return "⚪ \(name)"
        case .warn:
            return "🟡 \(name)"
        case .error:
            return "🔴 \(name)"
        case .fatal:
            return "💀 \(name)"
        }
    }
}
