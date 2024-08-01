//
//  ParraSessionManager+LogFormatters.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(
    bypassEventCreation: true,
    category: "LogFormatters"
)

extension ParraSessionManager {
    enum Constant {
        static let maxValueLength: Int = 80
    }

    func format(
        timestamp: Date,
        with style: ParraLoggerTimestampStyle
    ) -> String {
        let formatted: String = switch style {
        case .custom(let formatter):
            formatter.string(from: timestamp)
        case .epoch:
            "\(timestamp.timeIntervalSince1970)"
        case .iso8601:
            ParraInternal.Constants.Formatters.iso8601Formatter.string(
                from: timestamp
            )
        case .rfc3339:
            ParraInternal.Constants.Formatters.rfc3339DateFormatter.string(
                from: timestamp
            )
        }

        return formatted
    }

    func format(
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

    func format(
        callSite: ParraLoggerCallSiteContext,
        with style: ParraLoggerCallSiteStyleOptions
    ) -> String {
        var components = [String]()

        if style.contains(.file) {
            let (_, fileName, _) = LoggerHelpers.splitFileId(
                fileId: callSite.fileId
            )

            components.append(fileName)
        }

        if style.contains(.function) {
            components.append(callSite.simpleFunctionName)
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

    func format(
        extra: [String: Any]?,
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
                let data = try JSONEncoder.parraPrettyConsoleEncoder
                    .encode(AnyCodable(extra))

                // NSString is necessary to prevent additional escapes of quotations from being
                // added in the Xcode console.
                return NSString(
                    data: data,
                    encoding: NSUTF8StringEncoding
                ) as String?
            } catch {
                logger.error(
                    "Error formatting extra dictionary with style 'pretty'",
                    error
                )

                return String(describing: extra)
            }
        }
    }

    func format(callstackSymbols: ParraLoggerStackSymbols) -> String? {
        switch callstackSymbols {
        case .none:
            return nil
        case .raw(let frames):
            return frames.joined(separator: "\n")
        case .demangled(let frames):
            return frames.map { frame in
                return "\(frame.frameNumber)\t\(frame.binaryName)\t\(frame.address)\t\(frame.symbol) + \(frame.byteOffset)"
            }.joined(separator: "\n")
        }
    }

    func paddedIfPresent(
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
        of dictionary: [String: Any],
        to maxLength: Int
    ) -> [String: Any] {
        return dictionary.mapValues { value in
            if let stringValue = value as? String {
                return "\(stringValue.prefix(maxLength))..."
            } else if let dictValue = value as? [String: Any] {
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
