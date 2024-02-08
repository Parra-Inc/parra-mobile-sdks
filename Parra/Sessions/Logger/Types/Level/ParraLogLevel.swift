//
//  ParraLogLevel.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import os

public enum ParraLogLevel: Int, Comparable, ParraLogStringConvertible {
    case trace = 1
    case debug = 2
    case info = 4
    case warn = 8
    case error = 16
    case fatal = 32

    // MARK: Lifecycle

    init?(name: String) {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        {
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

    // MARK: Public

    public static let `default` = ParraLogLevel.info

    public static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    // MARK: Internal

    var requiresStackTraceCapture: Bool {
        return self >= .error
    }

    var osLogType: os.OSLogType {
        switch self {
        case .trace, .debug:
            return .debug
        case .info:
            return .info
        case .warn, .error:
            return .error
        case .fatal:
            return .fault
        }
    }
}
