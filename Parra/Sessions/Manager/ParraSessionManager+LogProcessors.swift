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
        switch wrappedEvent {
        case .internalEvent(let internalEvent, _):
            switch internalEvent {
            case .log(let logData):
                writeLogEventToConsoleSync(
                    processedLogData: logData,
                    with: consoleFormatOptions
                )
            default:
                writeGenericEventToConsoleSync(
                    wrappedEvent: wrappedEvent,
                    with: consoleFormatOptions
                )
            }
        case .event, .dataEvent:
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
        // Context:
        // Module -> file -> context -> subcontext -> ... -> subcontext -> call site module/file/function
//        let appleLogger = os.Logger(
//            subsystem: processedLogData.context?.module ?? "unknown module",
//            category: processedLogData.context?.fileName ?? "unknown file"
//        )

        if let categories = processedLogData.context?.categories {
            let catsString = categories.joined(separator: " -> ")

            let log = OSLog(
                subsystem: processedLogData.callSiteModule,
                category: .dynamicTracing
            )



            os_log(processedLogData.level.osLogType, log: log, "[\(Date().ISO8601Format(.iso8601))][\(processedLogData.level.name)][\(catsString)][\(processedLogData.message)]")

//            appleLogger.info("[\(Date().ISO8601Format(.iso8601))][\(processedLogData.level.name)][\(catsString)][\(processedLogData.message)]")
        } else {
            os_log(processedLogData.level.osLogType, "[\(Date().ISO8601Format(.iso8601))][\(processedLogData.level.name)][\(processedLogData.message)]")

//            appleLogger.info("[\(Date().ISO8601Format(.iso8601))][\(processedLogData.level.name)][\(processedLogData.message)]")
        }


        //        print(processedLogData.extra)
        //        let log = os.Logger(subsystem: "sub", category: "cat")
        //        log.info("test test test")

        //        var markerComponents: [String] = loggerOptions.compactMap { option in
        //            let component: String?
        //            switch option {
        //            case .printTimestamp(let style):
        //                component = format(
        //                    timestamp: .now,
        //                    with: style
        //                )
        //            case .printVerbosity(let style):
        //                component = format(
        //                    level: level,
        //                    with: style
        //                )
        //            case .printCallSite(let options):
        //                component = format(
        //                    callSite: callSiteContext,
        //                    with: options
        //                )
        //            }
        //
        //            return component
        //        }

        //        "╭─"
        //        "├─"
        //        "╰─"



        //        if loggerConfig.printTimestamps {
        //            markerComponents.append(timestamp)
        //        }
        //
        //        if loggerConfig.printModuleName {
        //            markerComponents.append(module)
        //        }
        //
        //        if loggerConfig.printFileName {
        //            markerComponents.append(file)
        //        }
        //
        //        if loggerConfig.printThread {
        //            markerComponents.append("🧵 \(queueName)")
        //        }

        //        let formattedMarkers = markerComponents.joined()
        //
        //        var formattedMessage: String
        ////        if loggerConfig.printVerbositySymbol {
        ////            formattedMessage = " \(level.symbol) \(formattedMarkers) \(baseMessage)"
        ////        } else {
        //            formattedMessage = "\(formattedMarkers) \(baseMessage)"
        ////        }
        //
        ////        if loggerConfig.printCallsite {
        ////            let formattedLocation = LoggerHelpers.createFormattedLocation(
        ////                fileId: callSiteContext.fileId,
        ////                function: callSiteContext.function,
        ////                line: callSiteContext.line
        ////            )
        ////            formattedMessage = "\(formattedMarkers) \(formattedLocation) \(baseMessage)"
        ////        }
        //
        //        if !extraWithAdditions.isEmpty {
        //            formattedMessage.append(contentsOf: "\n\u{2009}┃\t\(extraWithAdditions.debugDescription)")
        //        }
        //
        //        if let callStackSymbols {
        //            let formattedStackTrace = callStackSymbols.joined(separator: "\n")
        //
        //            formattedMessage.append(" - Call stack:\n\(formattedStackTrace)")
        //        }
        //
        //        print(formattedMessage)
    }

    /// -requirement: Must only ever be invoked from ``ParraSessionManager/eventQueue``
    internal func writeGenericEventToConsoleSync(
        wrappedEvent: ParraWrappedEvent,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
    }
}
