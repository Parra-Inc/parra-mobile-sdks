//
//  ParraLogger.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

public protocol ParraLogger: AnyObject {
    func log(level: ParraLogLevel,
             message: String,
             extra: [String: AnyHashable]?,
             file: String,
             fileID: String,
             function: String,
             line: Int)
}

fileprivate func _parraLog(_ message: String,
                           extra: [String: AnyHashable] = [:],
                           level: ParraLogLevel,
                           file: String,
                           fileID: String,
                           function: String,
                           line: Int) {
    Parra.config.loggerConfig.logger.log(
        level: level,
        message: message,
        extra: extra,
        file: file,
        fileID: fileID,
        function: function,
        line: line
    )
}

public func parraLog(_ message: @autoclosure () -> String,
                     extra: [String: AnyHashable] = [:],
                     level: ParraLogLevel = .info,
                     file: String = #file,
                     fileID: String = #fileID,
                     function: String = #function,
                     line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: level,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogT(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .trace,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogD(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .debug,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogI(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .info,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogW(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .warn,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogE(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .error,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogE(_ message: @autoclosure () -> ParraError,
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().errorDescription,
              extra: [:],
              level: .error,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogE(_ message: @autoclosure () -> Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().localizedDescription,
              extra: extra,
              level: .error,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogE(_ message: @autoclosure () -> String,
                      _ error: Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog("\(message()) error: \(error.localizedDescription)",
              extra: extra,
              level: .error,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogF(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(),
              extra: extra,
              level: .fatal,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogF(_ message: @autoclosure () -> ParraError,
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().errorDescription,
              extra: [:],
              level: .fatal,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogF(_ message: @autoclosure () -> Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message().localizedDescription,
              extra: extra,
              level: .fatal,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}

public func parraLogF(_ message: @autoclosure () -> String,
                      _ error: Error,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      fileID: String = #fileID,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog("\(message()) error: \(error.localizedDescription)",
              extra: extra,
              level: .fatal,
              file: file,
              fileID: fileID,
              function: function,
              line: line
    )
}
