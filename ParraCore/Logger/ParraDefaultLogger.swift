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
    static let timestampFormatter = ISO8601DateFormatter()

    var loggerConfig: ParraLoggerConfig = .default

    internal static let logQueue = DispatchQueue(
        label: "com.parra.default-logger",
        qos: .utility
    )

    func log(
        level: ParraLogLevel,
        message: ParraWrappedLogMessage,
        extraError: Error?,
        extra: [String : Any]?,
        fileID: String,
        function: String,
        line: Int
    ) {
        // A serial queue needs to be used to process log events in order to remove races and keep them in order.
        // This also means that we need to capture thread information before the context switch.

        let currentThread = Thread.current
        var callStackSymbols: [String]?
        if level == .fatal {
            callStackSymbols = Thread.callStackSymbols
        }

        ParraDefaultLogger.logQueue.async {
            self.processLog(
                level: level,
                message: message,
                extraError: extraError,
                extra: extra,
                fileID: fileID,
                function: function,
                line: line,
                currentThread: currentThread,
                callStackSymbols: callStackSymbols
            )
        }
    }

    private func processLog(
        level: ParraLogLevel,
        message: ParraWrappedLogMessage,
        extraError: Error?,
        extra: [String : Any]?,
        fileID: String,
        function: String,
        line: Int,
        currentThread: Thread,
        callStackSymbols: [String]?
    ) {
        guard level.isAllowed else {
            return
        }

        let baseMessage: String
        switch message {
        case .string(let messageProvider):
            baseMessage = messageProvider()
        case .error(let errorProvider):
            baseMessage = extractMessage(from: errorProvider())
        }

        let timestamp = ParraDefaultLogger.timestampFormatter.string(from: Date())
        let queue = currentThread.queueName
        let (module, file) = splitFileId(fileId: fileID)
        var extraWithAdditions = extra ?? [:]
        if let extraError {
            extraWithAdditions["errorDescription"] = extractMessage(from: extraError)
        }

#if DEBUG
        var markerComponents: [String] = []

        if loggerConfig.printTimestamps {
            markerComponents.append(timestamp)
        }

        if loggerConfig.printVerbosity {
            markerComponents.append(level.name)
        }

        if loggerConfig.printModuleName {
            markerComponents.append(module)
        }

        if loggerConfig.printFileName {
            markerComponents.append(file)
        }

        if loggerConfig.printThread {
            markerComponents.append("🧵 \(queue)")
        }

        let formattedMarkers = markerComponents.map { "[\($0)]" }.joined()

        var formattedMessage: String
        if loggerConfig.printVerbositySymbol {
            formattedMessage = " \(level.symbol) \(formattedMarkers) \(baseMessage)"
        } else {
            formattedMessage = "\(formattedMarkers) \(baseMessage)"
        }

        if loggerConfig.printCallsite {
            let formattedLocation = createFormattedLocation(fileID: fileID, function: function, line: line)
            formattedMessage = "\(formattedMarkers) \(formattedLocation) \(baseMessage)"
        }

        if !extraWithAdditions.isEmpty {
            formattedMessage.append(contentsOf: " \(extraWithAdditions.debugDescription)")
        }

        if let callStackSymbols {
            let formattedStackTrace = callStackSymbols.joined(separator: "\n")

            formattedMessage.append(" - Call stack:\n\(formattedStackTrace)")
        }

        print(formattedMessage)
#else
        var params = [String: Any]()
        params[ParraLoggerConfig.Constant.logEventMessageKey] = baseMessage
        params[ParraLoggerConfig.Constant.logEventLevelKey] = level.name
        params[ParraLoggerConfig.Constant.logEventTimestampKey] = timestamp
        params[ParraLoggerConfig.Constant.logEventFileKey] = file
        params[ParraLoggerConfig.Constant.logEventModuleKey] = module
        params[ParraLoggerConfig.Constant.logEventThreadKey] = queue
        params[ParraLoggerConfig.Constant.logEventThreadIdKey] = String(Thread.current.threadId)
        if !extraWithAdditions.isEmpty {
            params[ParraLoggerConfig.Constant.logEventExtraKey] = extraWithAdditions
        }
        if level >= .error {
            params[ParraLoggerConfig.Constant.logEventCallStackKey] = Thread.callStackSymbols
        }

        // TODO: Would capturing other info from ProcessInfo.processInfo.environment help with symbolication?

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.log, params: params)
#endif
    }

    private func extractMessage(from error: Error) -> String {
        if let parraError = error as? ParraError {
            return parraError.errorDescription
        } else {
            // Error is always bridged to NSError, can't downcast to check.
            if type(of: error) is NSError.Type {
                let nsError = error as NSError

                return "Error domain: \(nsError.domain), code: \(nsError.code), description: \(nsError.localizedDescription)"
            } else {
                return String(reflecting: error)
            }
        }
    }

    private func splitFileId(fileId: String) -> (module: String, fileName: String) {
        let initialSplit = {
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

        let (module, fileName) = initialSplit()

        let fileParts = fileName.split(separator: ".")
        if fileParts.count == 1 {
            return (module, fileName)
        } else {
            return (module, fileParts.dropLast(1).joined(separator: "."))
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
