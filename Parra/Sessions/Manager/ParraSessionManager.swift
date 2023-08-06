//
//  ParraSessionManager.swift
//  Parra
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

// TODO: Any logs used in here cause recursion in production
// TODO: General refactor for the Parra logger to just be a wrapper around writing log events to the session manager.

fileprivate let logger = Logger(bypassEventCreation: true, category: "Session manager")

// Needs
// 1. Logging events without waiting.
// 2. Thread safe state to know if there is pending sync data
// 3. Ability to wait on writes to finish when logging if desired
// 4. Open file handle when session starts
// 5. Log events to memory as soon as their written
// 6. Events are written to disk in batches
// 7. Certain high priority events trigger a write immediately

/// Handles receiving logs, session properties and events and coordinates passing these
/// to other services responsible for underlying storage.
///
/// Some important notes working with this class:
/// 1. For any method with the `Sync` suffix, you should always assume that it is a hard
///    requirement for it to be called on a specific queue. Usually ``eventQueue``.
internal class ParraSessionManager {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager
    private var loggerOptions: ParraLoggerOptions

    internal private(set) var currentSession: ParraSession?

    private var userProperties: [String : AnyCodable] = [:]

    fileprivate let eventQueue: DispatchQueue

    private var sessionStorage: SessionStorage {
        return dataManager.sessionStorage
    }

    internal init(
        dataManager: ParraDataManager,
        networkManager: ParraNetworkManager,
        loggerOptions: ParraLoggerOptions
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.loggerOptions = loggerOptions
        self.currentSession = ParraSession()

        // Set this in init after assigning the loggerOptions to ensure reads from the event queue couldn't
        // possibly start happening until after the initial write of these options is complete.
        eventQueue = DispatchQueue(
            label: "com.parra.sessions.event-queue",
            qos: .utility
        )
    }

    /// The config state will be exclusively accessed on a serial queue that will use
    /// barriers. Since Parra's config state uses an actor, it is illegal to attempt
    /// to access its value synchronously. So the safest thing to do is pass a copy
    /// to this class every time it updates, and process the change on the event queue.
    internal func updateLoggerOptions(loggerOptions: ParraLoggerOptions) {
        eventQueue.async {
            self.loggerOptions = loggerOptions
        }
    }

    internal func initializeSessions() async {
        await sessionStorage.initializeSessions()
    }

    internal func hasDataToSync() async -> Bool {
        // Sync if there are any sessions that aren't still in progress, or if the session
        // in progress has new events to report.
        if await sessionStorage.hasCompletedSessions() {
            return true
        }

        // TODO: Change the short circuit order here depending on which ends up being cheaper.

        return await sessionStorage.hasNewEvents()
    }

    func synchronizeData() async -> ParraSessionsResponse? {
        let syncLogger = logger.scope()

        // Reset and update the cache for the current session so the most up to take data is uploaded.
        await sessionStorage.recordSync()

        let sessionIterator = await sessionStorage.getAllSessions()

        var uploadedSessionIds = Set<String>()
        // It's possible that multiple sessions that are uploaded could receive a response indicating that polling
        // should occur. If this happens, we'll honor the most recent of these.
        var sessionResponse: ParraSessionsResponse?

        for await sessionUpload in sessionIterator {
            let session = sessionUpload.session

            do {
                syncLogger.debug("Uploading session: \(session.sessionId)")

                let response = try await networkManager.submitSession(sessionUpload)

                switch response.result {
                case .success(let payload):
                    // Don't override the session response unless it's another one with shouldPoll enabled.
                    if payload.shouldPoll {
                        sessionResponse = payload
                    }

                    uploadedSessionIds.insert(session.sessionId)
                case .failure(let error):
                    syncLogger.error(error)

                    // If any of the sessions fail to upload afty rerying, fail the entire operation
                    // returning the sessions that have been completed so far.
                    if response.attributes.contains(.exceededRetryLimit) {
                        break
                    }
                }
            } catch let error {
                syncLogger.error("Syncing sessions failed", error)
            }
        }

        await sessionStorage.deleteCompletedSessions(with: uploadedSessionIds)

        return sessionResponse
    }

    /// Logs the supplied event on the user's session.
    /// Do not interact with this method directly. Logging events should be done through the
    /// Parra.logEvent helpers.
    internal func writeEvent(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        eventQueue.async { [self] in
            writeEventSync(
                wrappedEvent: wrappedEvent,
                callSiteContext: callSiteContext
            )
        }
    }

    internal func writeEventSync(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        // When normal behavior isn't bypassed, debug behavior is to send logs to the console.
        // Production behavior is to write events.
        if loggerOptions.environment.hasDebugBehavior {
            writeEventToConsoleSync(
                wrappedEvent: wrappedEvent,
                with: loggerOptions.consoleFormatOptions
            )
        } else {
            writeEventToSessionSync(
                wrappedEvent: wrappedEvent,
                callSiteContext: callSiteContext
            )
        }
    }

    private func writeEventToSessionSync(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        sessionStorage.writeEvent(
            event: ParraSessionEvent(
                wrappedEvent: wrappedEvent,
                callSiteContext: callSiteContext
            )
        )
    }

    internal func setUserProperty(
        _ value: Any?,
        forKey key: String
    ) async {
//        await createSessionIfNotExists()
//
//        guard var currentSession else {
//            return
//        }
//
//        #if DEBUG
//        logger.debug("Updating user property", [
//            "key": key,
//            "new value": String(describing: value),
//            "old value": String(describing: self.userProperties[key])
//        ])
//        #endif
//
//        if let value {
//            userProperties[key] = .init(value)
//        } else {
//            userProperties.removeValue(forKey: key)
//        }
//
//        currentSession.updateUserProperties(userProperties)
//
//        do {
//            try await sessionStorage.update(
//                session: currentSession
//            )
//        } catch let error {
//            // TODO: Log error to console DIRECTLY
//        }
//
//        self.currentSession = currentSession
    }

    internal func resetSession() async {
//        guard var currentSession else {
//            return
//        }
//
//        currentSession.end()
//        currentSession.resetSentData()
//
//        do {
//            try await sessionStorage.update(
//                session: currentSession
//            )
//        } catch let error {
//            // TODO: Log error to console DIRECTLY
//        }
//
//        self.currentSession = nil
    }

    internal func endSession() async {
//        guard var currentSession else {
//            return
//        }
//
//        currentSession.end()
//
//        do {
//            try await sessionStorage.update(
//                session: currentSession
//            )
//        } catch let error {
//            // TODO: Log error to console DIRECTLY
//        }
//
//        self.currentSession = nil
    }

    internal func createSessionIfNotExists() async {
//        guard currentSession == nil else {
//            return
//        }
//
//        logger.debug("No session exists. Starting new session.")
//
//
//        var currentSession = ParraSession()
//
//        currentSession.updateUserProperties(userProperties)
//
//        do {
//            try await sessionStorage.update(
//                session: currentSession
//            )
//        } catch let error {
//            // TODO: Log error to console DIRECTLY
//        }
//
//        self.currentSession = currentSession
    }
}

// MARK: ParraLoggerBackend
extension ParraSessionManager: ParraLoggerBackend {
    internal func log(
        data: ParraLogData,
        bypassEventCreation: Bool
    ) {
        eventQueue.async { [self] in
            logEventReceivedSync(
                logData: data,
                bypassEventCreation: bypassEventCreation
            )
        }
    }

    internal func logMultiple(
        data: [ParraLogData],
        bypassEventCreation: Bool
    ) {
        eventQueue.async { [self] in
            for logData in data {
                logEventReceivedSync(
                    logData: logData,
                    bypassEventCreation: bypassEventCreation
                )
            }
        }
    }

    /// Any newly created log is required to pass through this method in order to ensure consistent
    /// filtering and processing. This method should always be called from the eventQueue.
    /// - Parameters:
    ///   - bypassEventCreation: This flag should be used for cases where we need to write logs
    ///   that can not trigger the creation of log events, and should instead just be written directly to
    ///   the console. This is primarily for places where writing events for logs would create recursion,
    ///   like logs generated by the services that store log events, for example. For now we will have a
    ///   blind spot in these places until a better solution is implemented.
    private func logEventReceivedSync(
        logData: ParraLogData,
        bypassEventCreation: Bool
    ) {
        guard logData.level >= loggerOptions.minimumLogLevel else {
            return
        }

        // At this point, the autoclosures passed to the logger functions are finally invoked.
        let processedLogData = ParraLogProcessedData(
            logData: logData
        )

        if bypassEventCreation {
            if loggerOptions.environment.hasDebugBehavior {
                writeLogEventToConsoleSync(
                    processedLogData: processedLogData,
                    with: loggerOptions.consoleFormatOptions
                )
            }
        } else {
            let wrappedEvent = ParraWrappedEvent.internalEvent(
                event: .log(logData: processedLogData)
            )

            writeEventSync(
                wrappedEvent: wrappedEvent,
                // Special case. Call site context is that of the origin of the log.
                callSiteContext: logData.callSiteContext
            )
        }
    }
}
