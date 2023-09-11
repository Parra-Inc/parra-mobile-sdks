//
//  ParraSessionManager+LogProcessors.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import os

// TODO: Markers are wrapper around OSSignPoster https://developer.apple.com/documentation/os/logging/recording_performance_data

// TODO: Automatically create os activity when creating a logger instance
//       auto apply events when logs happen. Auto handle child activities
//       when child loggers are created.
// https://developer.apple.com/documentation/os/logging/collecting_log_messages_in_activities

extension ParraSessionManager {
    /// -requirement: Must only ever be invoked from ``ParraSessionManager/eventQueue``
    internal func writeEventToConsoleSync(
        wrappedEvent: ParraWrappedEvent,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
        if case let .logEvent(event) = wrappedEvent {
            writeLogEventToConsoleSync(
                processedLogData: event.logData,
                with: consoleFormatOptions
            )
        } else {
            writeGenericEventToConsoleSync(
                wrappedEvent: wrappedEvent,
                with: consoleFormatOptions
            )
        }
    }

    /// -requirement: Must only ever be invoked from ``ParraSessionManager/eventQueue``
    internal func writeLogEventToConsoleSync(
        processedLogData: ParraLogProcessedData,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
        let messageSegments = consoleFormatOptions.compactMap { option in
            switch option {
            case .printMessage(let leftPad, let rightPad):
                return paddedIfPresent(
                    string: processedLogData.message,
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printTimestamps(let style, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        timestamp: processedLogData.timestamp,
                        with: style
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printLevel(let style, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        level: processedLogData.level,
                        with: style
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printCallSite(let options, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        callSite: processedLogData.callSiteContext,
                        with: options
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printExtras(let style, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        extra: processedLogData.extra,
                        with: style
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            }
        }

        let message = messageSegments.joined().trimmingCharacters(in: .whitespacesAndNewlines)

        let systemLogger = os.Logger(
            subsystem: processedLogData.subsystem,
            category: processedLogData.category
        )

        systemLogger.log(
            level: processedLogData.level.osLogType,
            "\(message)"
        )
    }

    /// -requirement: Must only ever be invoked from ``ParraSessionManager/eventQueue``
    internal func writeGenericEventToConsoleSync(
        wrappedEvent: ParraWrappedEvent,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
        print(wrappedEvent)
    }
}
