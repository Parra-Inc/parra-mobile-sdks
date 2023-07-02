//
//  ParraLogger.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

public protocol ParraLogger: AnyObject {
    func log(
        level: ParraLogLevel,
        // Messages should always be functions that return a message. This allows the logger to only execute potentially
        // expensive code if the logger is enabled. A wrapper object is provided to help differentiate between log types.
        message: ParraWrappedLogMessage,
        // When a primary message is provided but there is still an error object attached to the log.
        extraError: Error?,
        extra: [String: Any]?,
        // It is expected that #fileID is passed here for module resolution to function properly
        fileId: String,
        function: String,
        line: Int
    )
}

fileprivate func _parraLog(
    message: ParraWrappedLogMessage,
    extraError: Error? = nil,
    extra: [String: Any] = [:],
    level: ParraLogLevel,
    fileId: String,
    function: String,
    line: Int
) {
    ParraDefaultLogger.default.log(
        level: level,
        message: message,
        extraError: extraError,
        extra: extra,
        fileId: fileId,
        function: function,
        line: line
    )
}

// TODO: Wrap extra in its own autoclosure

public func parraLog(_ message: @autoclosure @escaping () -> String,
                     extra: [String: Any] = [:],
                     level: ParraLogLevel = .info,
                     fileId: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: level,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogTrace(_ message: @autoclosure @escaping () -> String,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .trace,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogDebug(_ message: @autoclosure @escaping () -> String,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .debug,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogInfo(_ message: @autoclosure @escaping () -> String,
                         _ extra: [String: Any] = [:],
                         fileId: String = #fileID,
                         function: String = #function,
                         line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .info,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogWarn(_ message: @autoclosure @escaping () -> String,
                         _ extra: [String: Any] = [:],
                         fileId: String = #fileID,
                         function: String = #function,
                         line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .warn,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure @escaping () -> String,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .error,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure @escaping () -> ParraError,
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .error(message),
        extra: [:],
        level: .error,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure @escaping () -> Error,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .error(message),
        extra: extra,
        level: .error,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure @escaping () -> String,
                          _ error: Error,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extraError: error,
        extra: extra,
        level: .error,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure @escaping () -> String,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extra: extra,
        level: .fatal,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure @escaping () -> Error,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .error(message),
        extra: extra,
        level: .fatal,
        fileId: fileId,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure @escaping () -> String,
                          _ error: Error,
                          _ extra: [String: Any] = [:],
                          fileId: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message: .string(message),
        extraError: error,
        extra: extra,
        level: .fatal,
        fileId: fileId,
        function: function,
        line: line
    )
}