//
//  Logger+VerbosityInstanceMethods.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Should there be one more layer of wrapper around these to try to obscure all the tracking via default values?

public extension Logger {
    @discardableResult
    func trace(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .trace,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func debug(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .debug,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func info(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .info,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func warn(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .warn,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func error(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func error(
        _ error: @autoclosure @escaping () -> ParraError,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .error(error),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func error(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .error,
            message: .error(error),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func error(
        _ message: @autoclosure @escaping () -> String,
        _ error: @autoclosure @escaping () -> Error? = { nil }(),
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
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
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func fatal(
        _ message: @autoclosure @escaping () -> String,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .fatal,
            message: .string(message),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func fatal(
        _ error: @autoclosure @escaping () -> Error,
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current,
            captureCallStack: true
        )
    ) -> ParraLogMarker {
        return logToBackend(
            level: .fatal,
            message: .error(error),
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }

    @discardableResult
    func fatal(
        _ message: @autoclosure @escaping () -> String,
        _ error: @autoclosure @escaping () -> Error? = { nil }(),
        _ extra: @autoclosure @escaping () -> [String: Any]? = { nil }(),
        _ callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
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
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )
    }
}
