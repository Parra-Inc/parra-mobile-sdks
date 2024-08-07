//
//  Logger+StaticLevels.swift
//  Parra
//
//  Created by Mick MacCallum on 7/7/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

//
//
// Heads up! This file contains a whole bunch of duplicated code that can't really be avoided.
// Here we provide a series of instance methods for the Logger that allow for logging at
// different levels and providing different parameters. We had to provide multiple overloads
// to keep these easy to use, and each requires capturing thread and call site information,
// which can not be abstracted out without captuing incorrect data.
//
//

import Foundation

// NOTE: All messages/errors/extras are wrapped in auto closures to prevent them from being evaluated
// until we're sure that the log will actually be displayed. If we ever consider adding more overloads
// that allow passing a closure directly, we will need consideration around the fact that it is
// possible that the closure may be executed more than once. For example, for a log that is printed to
// the console, but later has its message accessed during a measurement. This may be unexpected for users
// of the Logger if they added code that produced side effects in any of these closures.

public extension ParraLogger {
    @discardableResult
    @inlinable
    static func trace(
        _ message: String,
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
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func trace(
        _ message: String,
        _ extra: [String: Any],
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func debug(
        _ message: String,
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
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func debug(
        _ message: String,
        _ extra: [String: Any],
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func info(
        _ message: String,
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
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func info(
        _ message: String,
        _ extra: [String: Any],
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func warn(
        _ message: String,
        _ error: Error? = nil,
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
            extraError: error,
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func warn(
        _ message: String,
        _ extra: [String: Any],
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func warn(
        _ message: String,
        _ error: Error? = nil,
        _ extra: [String: Any],
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
            extraError: error,
            extra: extra,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ message: String,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .error,
            message: .string(message),
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ message: String,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ error: @autoclosure @escaping () -> ParraError,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .error,
            message: .error(error),
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ error: @autoclosure @escaping () -> ParraError,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ error: @autoclosure @escaping () -> Error,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .error,
            message: .error(error),
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ message: String,
        _ error: Error? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .error,
            message: .string(message),
            extraError: error,
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func error(
        _ message: String,
        _ error: Error? = nil,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ message: String,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .fatal,
            message: .string(message),
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ message: String,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ error: @autoclosure @escaping () -> Error,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .fatal,
            message: .error(error),
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ message: String,
        _ error: Error? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
        let callStackSymbols = Array(Thread.callStackSymbols.dropFirst(1))
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current,
            callStackSymbols: .raw(callStackSymbols)
        )

        return logToBackend(
            level: .fatal,
            message: .string(message),
            extraError: error,
            extra: nil,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @discardableResult
    @inlinable
    static func fatal(
        _ message: String,
        _ error: Error? = nil,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarker {
        // Call stack symbols must be captured directly within the body of these methods
        // to avoid capturing additional frames. We also drop the first frame because it
        // will always be the logger method. This means this can't be refactored to
        // deduplicate this logic.
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
                column: column,
                threadInfo: threadInfo
            )
        )
    }
}
