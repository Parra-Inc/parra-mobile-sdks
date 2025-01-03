//
//  ParraLogLevel+ConsoleOutput.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension ParraLogLevel {
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
            return "⚪️"
        case .warn:
            return "🟡"
        case .error:
            return "🔴"
        case .fatal:
            return "💀"
        }
    }

    var loggerDescription: String {
        switch self {
        case .trace:
            return "trace"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .warn:
            return "warn"
        case .error:
            return "error"
        case .fatal:
            return "fatal"
        }
    }
}
