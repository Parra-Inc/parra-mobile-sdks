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
        /// The maximum number of logs that can be collected before a logging backend is configured.
        /// Once the backend is set, the most recent logs (number by this variable) will be flushed to the backend.
        static let maxOrphanedLogBuffer = 100
    }

    /// A backend for all the methods for different verbosities provided by the Parra
    /// Logger. The logger backend is the place where log events should be written
    /// to console, disk, network, etc.
    internal static var loggerBackend: ParraLoggerBackend? {
        didSet {
            loggerBackendDidChange()
        }
    }

    internal let context: ParraLoggerContext
    internal private(set) weak var parent: Logger?

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
    private static let cachedLogsLock = UnfairLock()

    internal let fiberId: String?

    public init(
        category: String? = nil,
        extra: [String : Any]? = nil,
        fileId: String = #fileID,
        function: String = #function
    ) {
        bypassEventCreation = false
        fiberId = UUID().uuidString

        context = ParraLoggerContext(
            fiberId: fiberId,
            fileId: fileId,
            category: category,
            scope: .function(function),
            extra: extra ?? [:]
        )
    }

    internal init(
        bypassEventCreation: Bool,
        category: String? = nil,
        extra: [String : Any]? = nil,
        fileId: String = #fileID
    ) {
        self.bypassEventCreation = bypassEventCreation
        self.fiberId = UUID().uuidString
        self.context = ParraLoggerContext(
            fiberId: fiberId,
            fileId: fileId,
            category: category,
            scopes: [],
            extra: extra
        )
    }

    internal init(
        parent: Logger,
        context: ParraLoggerContext
    ) {
        self.bypassEventCreation = parent.bypassEventCreation
        self.fiberId = parent.fiberId
        self.context = context
        self.parent = parent
    }

    @usableFromInline
    internal func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: Error? = nil,
        extra: [String : Any]? = nil,
        callSiteContext: ParraLoggerCallSiteContext
    ) -> ParraLogMarker {
        let timestamp = Date.now
        let logContext = ParraLogContext(
            callSiteContext: callSiteContext,
            loggerContext: context,
            bypassEventCreation: bypassEventCreation
        )

        guard isEnabled else {
            return ParraLogMarker(
                timestamp: timestamp,
                message: message,
                initialLevel: level,
                initialLogContext: logContext
            )
        }

        let data = ParraLogData(
            timestamp: timestamp,
            level: level,
            message: message,
            extraError: extraError,
            extra: extra,
            logContext: logContext
        )

        if let loggerBackend = Logger.loggerBackend {
            loggerBackend.log(
                data: data
            )
        } else {
            Logger.collectLogWithoutDestination(data: data)
        }

        return ParraLogMarker(
            timestamp: timestamp,
            message: message,
            initialLevel: level,
            initialLogContext: logContext
        )
    }

    @usableFromInline
    internal static func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: Error? = nil,
        extra: [String : Any]? = nil,
        callSiteContext: ParraLoggerCallSiteContext
    ) -> ParraLogMarker {
        let timestamp = Date.now
        let logContext = ParraLogContext(
            callSiteContext: callSiteContext,
            loggerContext: nil,
            // Static logger methods do not have a way of changing this configuration (intentionally).
            bypassEventCreation: false
        )

        let data = ParraLogData(
            timestamp: timestamp,
            level: level,
            message: message,
            extraError: extraError,
            extra: extra,
            logContext: logContext
        )

        // We don't check that the logger is enabled here because this only applies to
        // logger instances.
        if let loggerBackend {
            loggerBackend.log(
                data: data
            )
        } else {
            collectLogWithoutDestination(data: data)
        }

        return ParraLogMarker(
            timestamp: timestamp,
            message: message,
            initialLevel: level,
            initialLogContext: logContext
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
        cachedLogsLock.locked {
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
                data: logCacheCopy
            )
        }
    }

    private static func collectLogWithoutDestination(
        data: ParraLogData
    ) {
        // TODO: Maybe reference the formatter directly here and in debug level/on in #DEBUG
        // print that the log had no destination because Parra isn't initialized.
        // Also set a flag to print this message the first time this happens and not every time.

        cachedLogsLock.locked {
            cachedLogs.append(data)

            if cachedLogs.count > Constant.maxOrphanedLogBuffer {
                let numToDrop = cachedLogs.count - Constant.maxOrphanedLogBuffer
                cachedLogs = Array(cachedLogs.dropFirst(numToDrop))
            }
        }
    }
}
