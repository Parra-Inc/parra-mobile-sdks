//
//  ParraLogger.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

public protocol ParraLogger: AnyObject {
    func log(
        level: ParraLogLevel,
        message: String,
        extra: [String: Any]?,
        // It is expected that #fileID is passed here for module resolution to function properly
        fileID: String,
        function: String,
        line: Int
    )
}

fileprivate func _parraLog(
    _ message: String,
    extra: [String: Any] = [:],
    level: ParraLogLevel,
    fileID: String,
    function: String,
    line: Int
) {
    Parra.config.loggerConfig.logger.log(
        level: level,
        message: message,
        extra: extra,
        fileID: fileID,
        function: function,
        line: line
    )
}

// TODO: Wrap extra in its own autoclosure

public func parraLog(_ message: @autoclosure () -> String,
                     extra: [String: Any] = [:],
                     level: ParraLogLevel = .info,
                     fileID: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: level,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogTrace(_ message: @autoclosure () -> String,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .trace,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogDebug(_ message: @autoclosure () -> String,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .debug,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogInfo(_ message: @autoclosure () -> String,
                         _ extra: [String: Any] = [:],
                         fileID: String = #fileID,
                         function: String = #function,
                         line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .info,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogWarn(_ message: @autoclosure () -> String,
                         _ extra: [String: Any] = [:],
                         fileID: String = #fileID,
                         function: String = #function,
                         line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .warn,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure () -> String,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .error,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure () -> ParraError,
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message().errorDescription,
        extra: [:],
        level: .error,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure () -> Error,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message().localizedDescription,
        extra: extra,
        level: .error,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogError(_ message: @autoclosure () -> String,
                          _ error: Error,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        "\(message()) error: \(error.localizedDescription)",
        extra: extra,
        level: .error,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure () -> String,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message(),
        extra: extra,
        level: .fatal,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure () -> ParraError,
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message().errorDescription,
        extra: [:],
        level: .fatal,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure () -> Error,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        message().localizedDescription,
        extra: extra,
        level: .fatal,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLogFatal(_ message: @autoclosure () -> String,
                          _ error: Error,
                          _ extra: [String: Any] = [:],
                          fileID: String = #fileID,
                          function: String = #function,
                          line: Int = #line) {
    _parraLog(
        "\(message()) error: \(error.localizedDescription)",
        extra: extra,
        level: .fatal,
        fileID: fileID,
        function: function,
        line: line
    )
}
