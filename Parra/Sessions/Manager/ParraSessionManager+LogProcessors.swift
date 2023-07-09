//
//  ParraSessionManager+LogProcessors.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Markers are wrapper around OSSignPoster https://developer.apple.com/documentation/os/logging/recording_performance_data

// TODO: Logger instances support instance method to return child logger

// TODO: Automatically create os activity when creating a logger instance
//       auto apply events when logs happen. Auto handle child activities
//       when child loggers are created.
// https://developer.apple.com/documentation/os/logging/collecting_log_messages_in_activities

extension ParraSessionManager {
    /// -requirement: Must only ever be invoked from ``ParraSessionManager/eventQueue``
    internal func process(
        logData: ParraLogData,
        with options: ParraLoggerOptions
    ) {
        guard logData.level >= options.minimumLogLevel else {
            return
        }

        // At this point, the autoclosures passed to the logger functions are finally invoked.
        let processedLogData = ParraLogProcessedData(
            logData: logData
        )

        if options.environment.hasDebugBehavior {
            outputDebugLog(
                processedLogData: processedLogData,
                with: options.consoleFormatOptions
            )
        } else {
            outputProductionLog(
                processedLogData: processedLogData
            )
        }
    }

    private func outputDebugLog(
        processedLogData: ParraLogProcessedData,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {
        // Context:
        // Module -> file -> context -> subcontext -> ... -> subcontext -> call site module/file/function


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

    private func outputProductionLog(
        processedLogData: ParraLogProcessedData
    ) {
        self.writeEventWithoutContextSwitch(
            event: ParraEventWrapper(
                event: .log(
                    logData: processedLogData
                )
            )
        )
    }
}
