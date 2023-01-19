//
//  ParraLogger.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

public struct ParraLoggerConfig {
    public var printTimestamps = true
    public var printLevel = true
    public var printThread = false
    public var printCallsite = true
    public var printPrefix: String? = "PARRA"

    static let `default` = ParraLoggerConfig()

    enum Constant {
        static let logEventPrefix = "parra:logger:"
        static let logEventMessageKey = "\(logEventPrefix)message"
        static let logEventLevelKey = "\(logEventPrefix)level"
        static let logEventTimestampKey = "\(logEventPrefix)timestamp"
        static let logEventThreadKey = "\(logEventPrefix)thread"
        static let logEventExtraKey = "\(logEventPrefix)extra"
    }
}

public enum ParraLogLevel: Int, Comparable {
    public static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case verbose = 1, info = 2, warn = 3, error = 4
    
    var isAllowed: Bool {
#if DEBUG
        return true
#else
        return self > .verbose
#endif
    }
    
    var outputName: String {
        switch self {
        case .verbose:
            return "🔵 VERBOSE"
        case .info:
            return "⚪ INFO"
        case .warn:
            return "🟡 WARN"
        case .error:
            return "🔴 ERROR"
        }
    }
}

fileprivate func _parraLog(_ message: String,
                           extra: [String: AnyHashable] = [:],
                           level: ParraLogLevel,
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
    let formattedLocation = createFormattedLocation(fileID: fileID, function: function, line: line)
    var formattedMessage = "\(formattedMarkers) \(formattedLocation) \(message)"

    if !extra.isEmpty {
        formattedMessage.append(contentsOf: " extra: \(extra.description)")
    }

    print(formattedMessage)
#else
    var params = [String: Any]()
    params[ParraLoggerConfig.Constant.logEventMessageKey] = message
    params[ParraLoggerConfig.Constant.logEventLevelKey] = level.outputName
    params[ParraLoggerConfig.Constant.logEventTimestampKey] = timestamp
    params[ParraLoggerConfig.Constant.logEventThreadKey] = queue
    if !extra.isEmpty {
        params[ParraLoggerConfig.Constant.logEventExtraKey] = extra
    }

    Parra.logAnalyticsEvent(ParraSessionEventType._Internal.log, params: params)
#endif
}

public func parraLog(_ message: @autoclosure () -> String,
                     extra: [String: AnyHashable] = [:],
                     level: ParraLogLevel = .info,
                     file: String = #file,
                     fileID: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
    _parraLog(message(), extra: extra, level: level, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogV(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .verbose, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogI(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .verbose, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogW(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .warn, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogE(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .error, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogE(_ message: @autoclosure () -> ParraError,
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().errorDescription, extra: [:], level: .error, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogE(_ message: @autoclosure () -> Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().localizedDescription, extra: extra, level: .error, file: file, fileID: fileID, function: function, line: line)
}

public func parraLogE(_ message: @autoclosure () -> String,
                      _ error: Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog("\(message()) error: \(error.localizedDescription)", extra: extra, level: .error, file: file, fileID: fileID, function: function, line: line)
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
