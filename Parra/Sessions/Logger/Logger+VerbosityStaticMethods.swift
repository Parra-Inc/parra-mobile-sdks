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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
        _ extra: @autoclosure @escaping () -> [String : Any]? = { nil }(),
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deuplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

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
