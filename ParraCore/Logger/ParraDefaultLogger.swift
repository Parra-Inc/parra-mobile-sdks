//
//  ParraDefaultLogger.swift
//  ParraCore
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal class ParraDefaultLogger: ParraLogger {
    static let `default` = ParraDefaultLogger()

    func log(level: ParraLogLevel,
             message: String,
             extra: [String : Any]?,
             fileID: String,
             function: String,
             line: Int) {

        guard level.isAllowed else {
            return
        }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let queue = Thread.current.queueName

#if DEBUG
        var markerComponents: [String] = []

        if Parra.config.loggerConfig.printTimestamps {
            markerComponents.append(timestamp)
        }

        if Parra.config.loggerConfig.printVerbosity {
            markerComponents.append(level.name)
        }

        if Parra.config.loggerConfig.printModuleName {
            let (module, _) = splitFileId(fileId: fileID)
            markerComponents.append(module)
        }

        if Parra.config.loggerConfig.printThread {
            markerComponents.append("🧵 \(queue)")
        }

        let formattedMarkers = markerComponents.map { "[\($0)]" }.joined()

        var formattedMessage: String
        if Parra.config.loggerConfig.printVerbositySymbol {
            formattedMessage = " \(level.symbol) \(formattedMarkers) \(message)"
        } else {
            formattedMessage = "\(formattedMarkers) \(message)"
        }

        if Parra.config.loggerConfig.printCallsite {
            let formattedLocation = createFormattedLocation(fileID: fileID, function: function, line: line)
            formattedMessage = "\(formattedMarkers) \(formattedLocation) \(message)"
        }

        let extraOrDefault = extra ?? [:]
        if !extraOrDefault.isEmpty {
            formattedMessage.append(contentsOf: " \(extraOrDefault.debugDescription)")
        }
        if level == .fatal {
            let formattedStackTrace = Thread.callStackSymbols.joined(separator: "\n")

            formattedMessage.append(" - Call stack:\n\(formattedStackTrace)")
        }

        print(formattedMessage)
#else
        let (module, file) = splitFileId(fileId: fileID)

        var params = [String: Any]()
        params[ParraLoggerConfig.Constant.logEventMessageKey] = message
        params[ParraLoggerConfig.Constant.logEventLevelKey] = level.name
        params[ParraLoggerConfig.Constant.logEventTimestampKey] = timestamp
        params[ParraLoggerConfig.Constant.logEventFileKey] = file
        params[ParraLoggerConfig.Constant.logEventModuleKey] = module
        params[ParraLoggerConfig.Constant.logEventThreadKey] = queue
        if let extra, !extra.isEmpty {
            params[ParraLoggerConfig.Constant.logEventExtraKey] = extra
        }
        if level >= .error {
            params[ParraLoggerConfig.Constant.logEventCallStackKey] = Thread.callStackSymbols
        }

        // TODO: Would capturing other info from ProcessInfo.processInfo.environment help with symbolication?

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.log, params: params)
#endif
    }

    private func splitFileId(fileId: String) -> (module: String, fileName: String) {
        let parts = fileId.split(separator: "/")

        if parts.count == 0 {
            return ("Unknown", "Unknown")
        } else if parts.count == 1 {
            return ("Unknown", String(parts[0]))
        } else if parts.count == 2 {
            return (String(parts[0]), String(parts[1]))
        } else {
            return (String(parts[0]), parts.dropFirst(1).joined(separator: "/"))
        }
    }

    private func createFormattedLocation(fileID: String, function: String, line: Int) -> String {
        let file: String
        if let extIndex = fileID.lastIndex(of: ".") {
            file = String(fileID[..<extIndex])
        } else {
            file = fileID
        }

        let functionName: String
        if let parenIndex = function.firstIndex(of: "(") {
            functionName = String(function[..<parenIndex])
        } else {
            functionName = function
        }

        return "\(file).\(functionName)#\(line)"
    }
}
