//
//  Logger+Levels.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
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

import Darwin
import Foundation

// TODO: Make another set of overloads that allow OSLogMessage/interpolation to be passed instead of string
//       Should there be one more layer of wrapper around these to try to obscure all the tracking via default values?
//       Related to ^, could we make use of @inlinable to do this, or to avoid having to parse Parra
//       frames out of stack traces? Also maybe help with Xcode 15 console showing button to jump to wrong file.

public extension Logger {
    @discardableResult
    @inlinable
    func trace(
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
    func trace(
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
    func debug(
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
    func debug(
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
    func info(
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
    func info(
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
    func warn(
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
            level: .warn,
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
    func warn(
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
    func error(
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
    func error(
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
    func error(
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
    func error(
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
    func error(
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
    func error(
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
    func error(
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
    func error(
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
    func fatal(
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
    func fatal(
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
    func fatal(
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
    func fatal(
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
    func fatal(
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
    func fatal(
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
