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
// TODO: Refactor and actually define scopes. Too much duplication in
//       module/file/etc. Should take child loggers into consideration.

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

        if options.environment.hasDebugBehavior {
            processDebugLog(
                logData: logData,
                with: options.consoleFormatOptions
            )
        } else {
            processProductionLog(logData: logData)
        }
    }

    private func processDebugLog(
        logData: ParraLogData,
        with consoleFormatOptions: [ParraLoggerConsoleFormatOption]
    ) {

    }

    private func processProductionLog(
        logData: ParraLogData
    ) {
        self.writeEventWithoutContextSwitch(
            event: ParraEventWrapper(
                event: ParraInternalEvent.log(
                    logData: logData
                )
            )
        )
    }
}

extension ParraSessionManager {

    private func _processLog(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error?,
        extra: @escaping () -> [String: Any]?,
        queueName: String,
        callStackSymbols: [String]?,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let baseMessage: String
        switch message {
        case .string(let messageProvider):
            baseMessage = messageProvider()
        case .error(let errorProvider):
            baseMessage = LoggerHelpers.extractMessage(
                from: errorProvider()
            )
        }

        let (module, file, _) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )
        var extraWithAdditions = extra() ?? [:]
        if let extraError = extraError() {
            extraWithAdditions["errorDescription"] = LoggerHelpers.extractMessage(
                from: extraError
            )
        }


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
}
