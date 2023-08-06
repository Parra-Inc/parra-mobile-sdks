//
//  Logger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public class Logger {
    private struct Constant {
        static let maxOrphanedLogBuffer = 100
    }

    /// A backend for all the methods for different verbosities provided by the Parra
    /// Logger. The logger backend is the place where log events should be written
    /// to console, disk, network, etc.
    internal static var loggerBackend: ParraLoggerBackend? {
        didSet {
            // TODO: Lock?
            loggerBackendDidChange()
        }
    }

    public let context: ParraLoggerContext
    public private(set) weak var parent: Logger?

    /// Whether or not logging is enabled on this logger instance. Logging is enabled
    /// by default. If you disable logging, logs are ignored until re-enabling. Changing this
    /// property will not affect any logs made before enabling/disabling the logger.
    public var isEnabled = true

    /// Wether logs written to this instance of the Logger should bypass being written to events
    /// for the session. This should always default to false and only be allowed to be enabled internally.
    internal private(set) var bypassEventCreation: Bool

    /// A cache of logs that occurred before the Parra SDK was initialized. Once initialization occurs
    /// these are meant to be flushed to the newly set logger backend.
    private static var cachedLogs = [ParraLogData]()

    public init(
        category: String? = nil,
        extra: [String : Any]? = nil,
        fileId: String = #fileID
    ) {
        bypassEventCreation = false

        if let category {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: [category],
                extra: extra ?? [:]
            )
        } else {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: [],
                extra: extra ?? [:]
            )
        }
    }

    internal convenience init(
        bypassEventCreation: Bool,
        category: String? = nil,
        extra: [String : Any]? = nil,
        fileId: String = #fileID
    ) {
        self.init(
            category: category,
            extra: extra,
            fileId: fileId
        )

        self.bypassEventCreation = bypassEventCreation
    }

    internal init(
        parent: Logger,
        context: ParraLoggerContext,
        bypassEventCreation: Bool
    ) {
        self.bypassEventCreation = bypassEventCreation
        self.context = context
        self.parent = parent
    }

    internal func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error? = { nil },
        extra: (() -> [String : Any])? = nil,
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        guard isEnabled else {
            return ParraLogMarker(
                initialLevel: level,
                message: message,
                initialCallSiteContext: callSiteContext
            )
        }

        let data = ParraLogData(
            level: level,
            context: context,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        if let loggerBackend = Logger.loggerBackend {
            loggerBackend.log(
                data: data,
                bypassEventCreation: bypassEventCreation
            )
        } else {
            Logger.collectLogWithoutDestination(data: data)
        }

        return ParraLogMarker(
            initialLevel: level,
            message: message,
            initialCallSiteContext: callSiteContext,
            context: self.context
        )
    }

    internal static func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        context: ParraLoggerContext? = nil,
        extraError: @escaping () -> Error? = { nil },
        extra: (() -> [String : Any])? = nil,
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        let data = ParraLogData(
            level: level,
            context: context,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        // We don't check that the logger is enabled here because this only applies to
        // logger instances.
        if let loggerBackend {
            loggerBackend.log(
                data: data,
                bypassEventCreation: false
            )
        } else {
            collectLogWithoutDestination(data: data)
        }

        return ParraLogMarker(
            initialLevel: level,
            message: message,
            initialCallSiteContext: callSiteContext,
            context: context
        )
    }

    /// Enabling logging on this logger instance. This update only applies to the current Logger
    /// instance and not to other instances or static Logger.info/etc methods. Logging is enabled by default.
    public func enable() {
        isEnabled = true
    }

    /// Disabling logging on this logger instance. This update only applies to the current Logger
    /// instance and not to other instances or static Logger.info/etc methods. Logging is enabled by default.
    public func disable() {
        isEnabled = false
    }

    private static func loggerBackendDidChange() {
        guard let loggerBackend else {
            // If the logger backend is unset or still not set, there is nowhere to flush the logs to.
            return
        }

        if cachedLogs.isEmpty {
            // Nothing to do with no cached logs
            return
        }

        // Copy and clear the cache since processing happens asynchronously
        let logCacheCopy = cachedLogs
        cachedLogs = []

        loggerBackend.logMultiple(
            data: logCacheCopy,
            bypassEventCreation: false
        )
    }

    private static func collectLogWithoutDestination(data: ParraLogData) {
        // TODO: Maybe reference the formatter directly here and in debug level/on in #DEBUG
        // print that the log had no destination because Parra isn't initialized.
        // Also set a flag to print this message the first time this happens and not every time.

        cachedLogs.append(data)

        if cachedLogs.count > Constant.maxOrphanedLogBuffer {
            let numToDrop = cachedLogs.count - Constant.maxOrphanedLogBuffer
            cachedLogs = Array(cachedLogs.dropFirst(numToDrop))
        }
    }
}
