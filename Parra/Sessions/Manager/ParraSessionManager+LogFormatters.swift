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
        var components = [String]()

        if style.contains(.function) {
            components.append(callSite.function)
        }

        if style.contains(.line) {
            components.append(String(callSite.line))
        }

        if style.contains(.column) {
            components.append(String(callSite.column))
        }
        
        let joined = components.joined(separator: ":")

        if style.contains(.thread) {
            return "[\(callSite.threadInfo.queueName)] \(joined)"
        }

        return joined
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

                // NSString is necessary to prevent additional escapes of quotations from being
                // added in the Xcode console.
                return NSString(data: data, encoding: NSUTF8StringEncoding) as String?
            } catch let error {
                logger.error("Error formatting extra dictionary with style 'pretty'", error)

                return nil
            }
        }
    }

    internal func format(callstackSymbols: ParraLoggerStackSymbols) -> String? {
        switch callstackSymbols {
        case .none:
            return nil
        case .raw(let frames):
            return frames.joined(separator: "\n")
        case .demangled(let frames):
            return frames.map({ frame in
                return "\(frame.frameNumber)\t\(frame.binaryName)\t\(frame.address)\t\(frame.symbol) + \(frame.byteOffset)"
            }).joined(separator: "\n")
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
