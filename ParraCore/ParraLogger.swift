//
//  ParraLogger.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

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
            return "[VERBOSE]"
        case .info:
            return "[INFO]"
        case .warn:
            return "[WARN]"
        case .error:
            return "[ERROR]"
        }
    }
}

fileprivate func _parraLog(_ message: String,
                           extra: [String: AnyHashable] = [:],
                           level: ParraLogLevel,
                           file: String,
                           function: String,
                           line: Int) {
    guard level.isAllowed else {
        return
    }
    
    var formattedMessage = "\(Parra.Constant.parraLogPrefix)\(level.outputName) \(message)"
    
    if !extra.isEmpty {
        formattedMessage.append(contentsOf: " extra: \(extra.description)")
    }
    
    print(formattedMessage)
}

public func parraLog(_ message: @autoclosure () -> String,
                     extra: [String: AnyHashable] = [:],
                     level: ParraLogLevel = .info,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
    _parraLog(message(), extra: extra, level: level, file: file, function: function, line: line)
}

public func parraLogV(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .verbose, file: file, function: function, line: line)
}

public func parraLogI(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .verbose, file: file, function: function, line: line)
}

public func parraLogW(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .warn, file: file, function: function, line: line)
}

public func parraLogE(_ message: @autoclosure () -> String,
                      _ extra: [String: AnyHashable] = [:],
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    _parraLog(message(), extra: extra, level: .error, file: file, function: function, line: line)
}
