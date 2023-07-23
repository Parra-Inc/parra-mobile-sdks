//
//  Logger+Logger+VerbosityStaticMethods.swift
//  Parra
//
//  Created by Mick MacCallum on 7/7/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Logger {
    @discardableResult
    static func trace(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .trace,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func debug(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .debug,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func info(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .info,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func warn(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .warn,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func error(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func error(
        _ error: @autoclosure @escaping () -> ParraError,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .error(error),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func error(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .error(error),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func error(
        _ message: @autoclosure @escaping () -> String,
        _ error: @autoclosure @escaping () -> Error? = { nil }(),
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .string(message),
            extraError: error,
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func fatal(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .fatal,
            message: .string(message),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func fatal(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .fatal,
            message: .error(error),
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }

    @discardableResult
    static func fatal(
        _ message: @autoclosure @escaping () -> String,
        _ error: @autoclosure @escaping () -> Error? = { nil }(),
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column,
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .fatal,
            message: .string(message),
            extraError: error,
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            ),
            threadInfo: threadInfo
        )
    }
}
