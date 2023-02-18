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
             file: String,
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

        if let prefix = Parra.config.loggerConfig.printPrefix {
            markerComponents.append(prefix)
        }

        if Parra.config.loggerConfig.printLevel {
            markerComponents.append(level.outputName)
        }

        if Parra.config.loggerConfig.printThread {
            markerComponents.append("🧵 \(queue)")
        }

        let formattedMarkers = markerComponents.map { "[\($0)]" }.joined()

        var formattedMessage = "\(formattedMarkers) \(message)"

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
        var params = [String: Any]()
        params[ParraLoggerConfig.Constant.logEventMessageKey] = message
        params[ParraLoggerConfig.Constant.logEventLevelKey] = level.name
        params[ParraLoggerConfig.Constant.logEventTimestampKey] = timestamp
        params[ParraLoggerConfig.Constant.logEventThreadKey] = queue
        if !extra.isEmpty {
            params[ParraLoggerConfig.Constant.logEventExtraKey] = extra
        }
        if level >= .error {
            params[ParraLoggerConfig.Constant.logEventCallStackKey] = Thread.callStackSymbols
        }

        // TODO: Would capturing other info from ProcessInfo.processInfo.environment help with symbolication?

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.log, params: params)
#endif
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
