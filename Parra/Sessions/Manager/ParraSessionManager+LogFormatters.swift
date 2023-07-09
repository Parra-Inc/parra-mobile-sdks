//
//  ParraSessionManager+LogFormatters.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraSessionManager {
    internal func format(
        timestamp: Date,
        with style: ParraLoggerTimestampStyle
    ) -> String? {
        let formatted: String
        switch style {
        case .custom(let formatter):
            formatted = formatter.string(from: timestamp)
        case .epoch:
            formatted = "\(timestamp.timeIntervalSince1970)"
        case .iso8601:
            formatted = Parra.InternalConstants.Formatters.iso8601Formatter.string(
                from: timestamp
            )
        case .rfc3339:
            formatted = Parra.InternalConstants.Formatters.rfc3339DateFormatter.string(
                from: timestamp
            )
        case .none:
            return nil
        }

        return "[\(formatted)]"
    }

    internal func format(
        level: ParraLogLevel,
        with style: ParraLoggerLevelStyle
    ) -> String {
        switch style {
        case .symbol:
            return level.symbol
        case .word:
            return "[\(level.name)]"
        case .both:
            return "\(level.symbol) [\(level.name)]"
        }
    }

    internal func format(
        callSite: ParraLoggerCallSiteContext,
        with style: ParraLoggerCallSiteStyleOptions
    ) -> String {
        //        style.contains(.function)

        return ""
    }
}
