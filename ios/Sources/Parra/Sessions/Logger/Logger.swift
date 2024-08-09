//
//  Logger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import os

typealias Logger = ParraLogger

public class ParraLogger {
    // MARK: - Lifecycle

    public init(
        category: String? = nil,
        extra: [String: Any]? = nil,
        fileId: String = #fileID,
        function: String = #function
    ) {
        self.bypassEventCreation = false
        self.fiberId = UUID().uuidString
        self.context = ParraLoggerContext(
            fiberId: fiberId,
            fileId: fileId,
            category: Logger.categoryOrDefault(
                category: category,
                fileId: fileId
            ),
            scope: .function(function),
            extra: extra ?? [:]
        )
    }

    init(
        bypassEventCreation: Bool,
        category: String? = nil,
        extra: [String: Any]? = nil,
        fileId: String = #fileID
    ) {
        self.bypassEventCreation = bypassEventCreation
        self.fiberId = UUID().uuidString
        self.context = ParraLoggerContext(
            fiberId: fiberId,
            fileId: fileId,
            category: Logger.categoryOrDefault(
                category: category,
                fileId: fileId
            ),
            scopes: [],
            extra: extra
        )
    }

    init(
        parent: Logger,
        context: ParraLoggerContext
    ) {
        self.bypassEventCreation = parent.bypassEventCreation
        self.fiberId = parent.fiberId
        self.context = context
        self.parent = parent
    }

    // MARK: - Public

    /// Whether or not logging is enabled on this logger instance. Logging is enabled
    /// by default. If you disable logging, logs are ignored until re-enabling. Changing this
    /// property will not affect any logs made before enabling/disabling the logger.
    public var isEnabled = true

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

    // MARK: - Internal

    /// A backend for all the methods for different verbosities provided by the Parra
    /// Logger. The logger backend is the place where log events should be written
    /// to console, disk, network, etc.
    static var loggerBackend: ParraLoggerBackend? {
        didSet {
            loggerBackendDidChange()
        }
    }

    let context: ParraLoggerContext
    private(set) weak var parent: Logger?

    /// Wether logs written to this instance of the Logger should bypass being written to events
    /// for the session. This should always default to false and only be allowed to be enabled internally.
    private(set) var bypassEventCreation: Bool

    let fiberId: String?

    @usableFromInline
    static func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: Error? = nil,
        extra: [String: Any]? = nil,
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

    @usableFromInline
    func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: Error? = nil,
        extra: [String: Any]? = nil,
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

    // MARK: - Private

    private enum Constant {
        /// The maximum number of logs that can be collected before a logging backend is configured.
        /// Once the backend is set, the most recent logs (number by this variable) will be flushed to the backend.
        static let maxOrphanedLogBuffer = 100
    }

    /// A cache of logs that occurred before the Parra SDK was initialized. Once initialization occurs
    /// these are meant to be flushed to the newly set logger backend.
    private static let cachedLogsLock =
        OSAllocatedUnfairLock(initialState: [ParraLogData]())

    private static func loggerBackendDidChange() {
        cachedLogsLock.withLock { cachedLogs in
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
        cachedLogsLock.withLock { cachedLogs in
            cachedLogs.append(data)

            if cachedLogs.count > Constant.maxOrphanedLogBuffer {
                let numToDrop = cachedLogs.count - Constant.maxOrphanedLogBuffer
                cachedLogs = Array(cachedLogs.dropFirst(numToDrop))
            }
        }
    }

    private static func categoryOrDefault(
        category: String?,
        fileId: String
    ) -> String {
        if let category {
            return category
        }

        let (_, fileName) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        return fileName
    }
}
