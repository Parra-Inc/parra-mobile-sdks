//
//  ParraFeedbackLogger.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

enum ParraLogLevel: Int, Comparable {
    static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
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
                           level: ParraLogLevel,
                           file: String,
                           function: String,
                           line: Int) {
    guard level.isAllowed else {
        return
    }
    
    print("\(ParraFeedback.Constants.parraLogPrefix)\(level.outputName) \(message)")
}

internal func parraLog(_ message: @autoclosure () -> String,
                       level: ParraLogLevel = .info,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {
    _parraLog(message(), level: level, file: file, function: function, line: line)
}

internal func parraLogV(_ message: @autoclosure () -> String,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
    _parraLog(message(), level: .verbose, file: file, function: function, line: line)
}

internal func parraLogI(_ message: @autoclosure () -> String,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
    _parraLog(message(), level: .verbose, file: file, function: function, line: line)
}

internal func parraLogW(_ message: @autoclosure () -> String,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
    _parraLog(message(), level: .warn, file: file, function: function, line: line)
}

internal func parraLogE(_ message: @autoclosure () -> String,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
    _parraLog(message(), level: .error, file: file, function: function, line: line)
}
