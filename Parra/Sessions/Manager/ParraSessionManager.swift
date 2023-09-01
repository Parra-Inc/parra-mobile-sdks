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
    internal func updateLoggerOptions(
        loggerOptions: ParraLoggerOptions
    ) {
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
            logger.debug("has completed sessions to sync")
            return true
        }

        // TODO: Change the short circuit order here depending on which ends up being cheaper.

        let hasNewEvents = await sessionStorage.hasNewEvents()

        logger.debug("has new events to sync: \(hasNewEvents)")

        return hasNewEvents
    }

    func synchronizeData() async throws -> ParraSessionsResponse? {
        return try await logger.withScope { logger in
            let currentSession = await sessionStorage.getCurrentSession()
            let sessionIterator = try await sessionStorage.getAllSessions()

            var uploadedSessionIds = Set<String>()
            // It's possible that multiple sessions that are uploaded could receive a response indicating that polling
            // should occur. If this happens, we'll honor the most recent of these.
            var sessionResponse: ParraSessionsResponse?

            for await sessionUpload in sessionIterator {
                logger.trace("Session upload iterator produced session", [
                    "sessionId": String(describing: sessionUpload?.session.sessionId)
                ])
                guard let sessionUpload else {
                    // The iterator can't return nil until the sequence is complete. If a the inner optional
                    // is nil, it indicates that we should skip this session for one reason or another. It may
                    // have been corrupted, or an incorrect file type made it into the session directory, etc.
                    continue
                }

                let session = sessionUpload.session

                if currentSession.sessionId == session.sessionId {
                    // Sets a marker on the current session to indicate the offset of the file handle that stores events
                    // just before the sync starts. This is necessary to make sure that any new events that roll in
                    // while the sync is in progress aren't deleted as part of post-sync cleanup.
                    await sessionStorage.recordSyncBegan()
                }

                do {
                    logger.debug("Uploading session: \(session.sessionId)")

                    let response = try await networkManager.submitSession(sessionUpload)

                    switch response.result {
                    case .success(let payload):
                        // Don't override the session response unless it's another one with shouldPoll enabled.
                        if payload.shouldPoll {
                            sessionResponse = payload
                        }

                        uploadedSessionIds.insert(session.sessionId)
                    case .failure(let error):
                        logger.error(error)

                        // If any of the sessions fail to upload afty rerying, fail the entire operation
                        // returning the sessions that have been completed so far.
                        if response.attributes.contains(.exceededRetryLimit) {
                            break
                        }
                    }
                } catch let error {
                    logger.error("Syncing sessions failed", error)
                }
            }

            await sessionStorage.deleteSynchronizedData(
                for: uploadedSessionIds
            )

            return sessionResponse

        }
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
                target: .automatic,
                callSiteContext: callSiteContext
            )
        }
    }

    internal func writeEventSync(
        wrappedEvent: ParraWrappedEvent,
        target: ParraSessionEventTarget,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let environment = loggerOptions.environment
        // When normal behavior isn't bypassed, debug behavior is to send logs to the console.
        // Production behavior is to write events.

        let writeToConsole = { [self] in
            writeEventToConsoleSync(
                wrappedEvent: wrappedEvent,
                with: loggerOptions.consoleFormatOptions
            )
        }

        let writeToSession = { [self] in
            writeEventToSessionSync(
                wrappedEvent: wrappedEvent,
                callSiteContext: callSiteContext
            )
        }

        switch target {
        case .all:
            writeToConsole()
            writeToSession()
        case .automatic:
            if environment.hasConsoleBehavior {
                writeToConsole()
            } else {
                writeToSession()
            }
        case .console:
            writeToConsole()
        case .session:
            writeToSession()
        case .none:
            // The event is explicitly being skipped.
            break
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
    ) {
        sessionStorage.writeUserPropertyUpdate(
            key: key,
            value: value
        )
    }

    internal func endSession() async {
        await sessionStorage.endSession()
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

        let wrappedEvent = ParraWrappedEvent.internalEvent(
            event: .log(logData: processedLogData)
        )

        // 1. The flag to bypass event creation takes precedence, since this is used in cases like logs
        // within the logging infrastructure that could cause recursion in error cases. If it is set
        // we send logs to the console instead of the session in DEBUG mode. Since the automatic behavior
        // in RELEASE is to write to sessions, we skip writing entirely in this case.
        // TODO: This will eventually need to be addressed to help catch errors in this part of our code.
        //
        // 2. The next check is for the event debug logging override flag, which is set by any environmental
        // variable. This is used to allow us to force writing to both sessions and the consoles during
        // development for testing purposes.
        //
        // 3. Fall back on the default behavior that takes scheme and user preferences into consideration.

        let target: ParraSessionEventTarget
        if bypassEventCreation {
#if DEBUG
            target = .console
#else
            target = .none
#endif
        } else if ParraLoggerEnvironment.eventDebugLoggingOverrideEnabled {
            target = .all
        } else {
            target = .automatic
        }

        writeEventSync(
            wrappedEvent: wrappedEvent,
            target: target,
            // Special case. Call site context is that of the origin of the log.
            callSiteContext: logData.callSiteContext
        )
    }
}
