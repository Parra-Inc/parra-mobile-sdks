//
//  ParraSessionManager+LogFormatters.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

fileprivate let logger = Logger(bypassEventCreation: true, category: "LogFormatters")

extension ParraSessionManager {
    internal struct Constant {
        static let maxValueLength: Int = 80
    }

    internal func format(
        timestamp: Date,
        with style: ParraLoggerTimestampStyle
    ) -> String {
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
        }

        return formatted
    }

    internal func format(
        level: ParraLogLevel,
        with style: ParraLoggerLevelStyle
    ) -> String {
        switch style {
        case .symbol:
            return level.symbol
        case .word:
            return level.name
        case .both:
            return "\(level.symbol) \(level.name)"
        }
    }

    internal func format(
        callSite: ParraLoggerCallSiteContext,
        with style: ParraLoggerCallSiteStyleOptions
    ) -> String {
        callSite.
        return "\(callSite.simpleFunctionName):\(callSite.line):\(callSite.column)"
    }

    internal func format(
        extra: [String : Any]?,
        with style: ParraLoggerExtraStyle
    ) -> String? {
        guard let extra, !extra.isEmpty else {
            return nil
        }

        switch style {
        case .raw:
            return extra.description
        case .condensed:
            return recursivelyTruncateValues(
                of: extra,
                to: Constant.maxValueLength
            ).description
        case .pretty:
            do {
                // TODO: Should this be JSON?
                let data = try JSONEncoder.parraPrettyConsoleEncoder.encode(AnyCodable(extra))

                return String(data: data, encoding: .utf8)
            } catch let error {
                logger.error("Error formatting extra dictionary with style 'pretty'", error)

                return nil
            }
        }
    }

    internal func paddedIfPresent(
        string: String?,
        leftPad: String,
        rightPad: String
    ) -> String? {
        guard let string else {
            return nil
        }

        return leftPad + string + rightPad
    }

    private func recursivelyTruncateValues(
        of dictionary: [String : Any],
        to maxLength: Int
    ) -> [String : Any] {
        return dictionary.mapValues { value in
            if let stringValue = value as? String {
                return "\(stringValue.prefix(maxLength))..."
            } else if let dictValue = value as? [String : Any] {
                return recursivelyTruncateValues(
                    of: dictValue,
                    to: maxLength
                )
            } else {
                return value
            }
        }
    }
}
