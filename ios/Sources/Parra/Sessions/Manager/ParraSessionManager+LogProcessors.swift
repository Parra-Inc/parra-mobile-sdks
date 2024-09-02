//
//  ParraSessionManager+LogProcessors.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import os

// TODO: Markers are wrapper around OSSignPoster
// https://developer.apple.com/documentation/os/logging/recording_performance_data

// TODO: Automatically create os activity when creating a logger instance
//       auto apply events when logs happen. Auto handle child activities
//       when child loggers are created.
// https://developer.apple.com/documentation/os/logging/collecting_log_messages_in_activities

extension SessionManager {
    /// -requirement: Must only ever be invoked from ``SessionManager/eventQueue``
    func writeEventToConsoleSync(
        wrappedEvent: ParraWrappedEvent,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption],
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        if case .logEvent(let event) = wrappedEvent {
            writeLogEventToConsoleSync(
                processedLogData: event.logData,
                with: consoleFormatOptions
            )

            return
        }

        let (_, displayName, combinedExtra) = ParraSessionEvent
            .normalizedEventData(
                from: wrappedEvent
            )

        writeSessionEventToConsole(
            named: displayName,
            extra: combinedExtra,
            isInternalEvent: wrappedEvent.isInternal,
            with: consoleFormatOptions,
            callSiteContext: callSiteContext
        )
    }

    /// -requirement: Must only ever be invoked from ``SessionManager/eventQueue``
    private func writeLogEventToConsoleSync(
        processedLogData: ParraLogProcessedData,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
        let messageSegments = createMessageSegments(
            for: consoleFormatOptions,
            message: processedLogData.message,
            timestamp: processedLogData.timestamp,
            level: processedLogData.level,
            extra: processedLogData.extra,
            callSiteContext: processedLogData.callSiteContext
        )

        var message = messageSegments.joined().trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if processedLogData.level.requiresStackTraceCapture {
            let callstackSymbols = processedLogData.callSiteContext.threadInfo
                .callStackSymbols

            if let formattedStackTrace = format(
                callstackSymbols: callstackSymbols
            ) {
                message.append("\n")
                message.append(formattedStackTrace)
            }
        }

        let systemLogger = os.Logger(
            subsystem: processedLogData.subsystem,
            category: processedLogData.category
        )

        writeMessageToDebugView(message)

        systemLogger.log(
            level: processedLogData.level.osLogType,
            "\(message)"
        )
    }

    /// Events that are specifically not log events. Anything that happened during the session. User actions,
    /// async system events, etc, but not logs.
    private func writeSessionEventToConsole(
        named name: String,
        extra: [String: Any],
        isInternalEvent: Bool,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption],
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let messageSegments = createMessageSegments(
            for: consoleFormatOptions,
            message: name,
            timestamp: .now,
            level: nil,
            // Internal events shouldn't reveal extra data in console logs.
            extra: isInternalEvent ? nil : extra,
            callSiteContext: callSiteContext
        )

        let subsystem = "Parra Event"
        let category = isInternalEvent ? "Internal" : "User Generated"
        let prefix = "✨ [\(subsystem)][\(category)]"
        let message = messageSegments.joined().trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let systemLogger = os.Logger(
            subsystem: subsystem,
            category: category
        )

        let finalMessage = "\(prefix)\(message)"

        writeMessageToDebugView(finalMessage)

        systemLogger.log(
            level: .default,
            "\(finalMessage)"
        )
    }

    private func writeMessageToDebugView(_ message: String) {
        if !AppEnvironment.isParraDemoBeta {
            return
        }

        Task { @MainActor in
            DebugLogStore.shared.write(message)
        }
    }

    private func createMessageSegments(
        for consoleFormatOptions: [ParraLoggerConsoleFormatOption],
        message: String,
        timestamp: Date,
        level: ParraLogLevel?,
        extra: [String: Any]?,
        callSiteContext: ParraLoggerCallSiteContext
    ) -> [String] {
        return consoleFormatOptions.compactMap { option in
            switch option {
            case .printMessage(let leftPad, let rightPad):
                return paddedIfPresent(
                    string: message,
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printTimestamps(let style, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        timestamp: timestamp,
                        with: style
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printLevel(let style, let leftPad, let rightPad):
                if let level {
                    return paddedIfPresent(
                        string: format(
                            level: level,
                            with: style
                        ),
                        leftPad: leftPad,
                        rightPad: rightPad
                    )
                }

                return nil
            case .printCallSite(let options, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        callSite: callSiteContext,
                        with: options
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            case .printExtras(let style, let leftPad, let rightPad):
                return paddedIfPresent(
                    string: format(
                        extra: extra,
                        with: style
                    ),
                    leftPad: leftPad,
                    rightPad: rightPad
                )
            }
        }
    }
}
