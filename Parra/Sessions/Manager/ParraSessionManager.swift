//
//  ParraSessionManager.swift
//  Parra
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

// NOTE: Any logs used in here cause recursion in production

private let logger = Logger(
    bypassEventCreation: true,
    category: "Session manager"
)

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
@usableFromInline
class ParraSessionManager {
    // MARK: - Lifecycle

    init(
        dataManager: ParraDataManager,
        networkManager: ParraNetworkManager,
        loggerOptions: ParraLoggerOptions
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.loggerOptions = loggerOptions

        // Set this in init after assigning the loggerOptions to ensure reads from the event queue couldn't
        // possibly start happening until after the initial write of these options is complete.
        self.eventQueue = DispatchQueue(
            label: "com.parra.sessions.event-queue",
            qos: .utility
        )
    }

    // MARK: - Internal

    func initializeSessions() async {
        await sessionStorage.initializeSessions()
    }

    func hasDataToSync(since date: Date?) async -> Bool {
        // Checks made in order by least resources required to check them:
        // 1. The current session has been updated
        // 2. There are new events
        // 3. There are previous sessions

        return await logger.withScope { logger in
            if await sessionStorage.hasSessionUpdates(since: date) {
                logger.trace("has updates to current session")

                return true
            }

            if await sessionStorage.hasNewEvents() {
                logger.trace("has new events on current session")

                return true
            }

            // If there are sessions other than the one in progress, they should be synced.
            if await sessionStorage.hasCompletedSessions() {
                logger.trace("has completed sessions")

                return true
            }

            logger.trace("no updates require sync")

            return false
        }
    }

    func synchronizeData() async throws -> ParraSessionsResponse? {
        return try await logger.withScope { logger in
            let currentSession = try await sessionStorage.getCurrentSession()
            let sessionIterator = try await sessionStorage.getAllSessions()

            var removableSessionIds = Set<String>()
            var erroredSessionIds = Set<String>()

            let markSessionForDirectoryAsErrored = { (directory: URL) in
                let ext = ParraSession.Constant.packageExtension
                guard directory.pathExtension == ext else {
                    return
                }

                let sessionId = directory.deletingPathExtension()
                    .lastPathComponent

                // A session directory being prefixed with an underscore indicates that we
                // have already made an attempt to synchronize it, which has failed.
                // If the session has failed to synchronize again, we want to cut our
                // losses and delete it, so it doesn't cause the sync manager to think
                // there are more sessions to sync.

                if sessionId
                    .hasPrefix(ParraSession.Constant.erroredSessionPrefix)
                {
                    logger
                        .trace(
                            "Marking previously errored session for removal: \(sessionId)"
                        )

                    removableSessionIds.insert(sessionId)
                } else {
                    logger.trace("Marking session as errored: \(sessionId)")

                    erroredSessionIds.insert(sessionId)
                }
            }

            // It's possible that multiple sessions that are uploaded could receive a response indicating that polling
            // should occur. If this happens, we'll honor the most recent of these.
            var sessionResponse: ParraSessionsResponse?

            for await nextSession in sessionIterator {
                switch nextSession {
                case .success(let sessionDirectory, let sessionUpload):
                    logger.trace("Session upload iterator produced session", [
                        "sessionId": String(describing: sessionUpload.session
                            .sessionId)
                    ])

                    // Reference the session ID from the path instead of from reading the session
                    // object, since this one will include the deletion marker.
                    let sessionId = sessionDirectory.deletingPathExtension()
                        .lastPathComponent

                    if currentSession.sessionId == sessionId {
                        // Sets a marker on the current session to indicate the offset of the file handle that stores events
                        // just before the sync starts. This is necessary to make sure that any new events that roll in
                        // while the sync is in progress aren't deleted as part of post-sync cleanup.
                        await sessionStorage.recordSyncBegan()
                    }

                    logger.debug("Uploading session: \(sessionId)")

                    let response = await networkManager.submitSession(
                        sessionUpload
                    )

                    switch response.result {
                    case .success(let payload):
                        logger
                            .debug(
                                "Successfully uploaded session: \(sessionId)"
                            )

                        // Don't override the session response unless it's another one with shouldPoll enabled.
                        if payload.shouldPoll {
                            sessionResponse = payload
                        }

                        removableSessionIds.insert(sessionId)
                    case .failure(let error):
                        logger.error(
                            "Failed to upload session: \(sessionId)",
                            error
                        )

                        markSessionForDirectoryAsErrored(sessionDirectory)

                        // If any of the sessions fail to upload afty rerying, fail the entire operation
                        // returning the sessions that have been completed so far.
                        if response.attributes.contains(.exceededRetryLimit) {
                            logger.debug(
                                "Network retry limited exceeded. Will not attempt to sync additional sessions."
                            )
                            break
                        }
                    }
                case .error(let sessionDirectory, let error):
                    markSessionForDirectoryAsErrored(sessionDirectory)

                    logger.error("Error synchronizing session", error)
                }
            }

            try await sessionStorage.deleteSessions(
                for: removableSessionIds,
                erroredSessions: erroredSessionIds
            )

            return sessionResponse
        }
    }

    /// Logs the supplied event on the user's session.
    /// Do not interact with this method directly. Logging events should be done through the
    /// Parra.logEvent helpers.
    @usableFromInline
    func writeEvent(
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

    func writeEventSync(
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
                with: loggerOptions.consoleFormatOptions,
                callSiteContext: callSiteContext
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
                #if DEBUG
                // If we're running tests, honor the configured behavior, but also write
                // to console, if we weren't already going to.
                if NSClassFromString("XCTestCase") != nil {
                    writeToConsole()
                }
                #endif
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

    func setUserProperty(
        _ value: Any?,
        forKey key: String
    ) {
        sessionStorage.writeUserPropertyUpdate(
            key: key,
            value: value
        )
    }

    func endSession() async {
        await sessionStorage.endSession()
    }

    // MARK: - Private

    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager
    private let loggerOptions: ParraLoggerOptions

    private let eventQueue: DispatchQueue

    private var sessionStorage: SessionStorage {
        return dataManager.sessionStorage
    }

    private func writeEventToSessionSync(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let (event, context) = ParraSessionEvent.sessionEventFromEventWrapper(
            wrappedEvent: wrappedEvent,
            callSiteContext: callSiteContext
        )

        sessionStorage.writeEvent(
            event: event,
            context: context
        )
    }
}

// MARK: ParraLoggerBackend

extension ParraSessionManager: ParraLoggerBackend {
    func log(
        data: ParraLogData
    ) {
        eventQueue.async { [self] in
            logEventReceivedSync(
                logData: data
            )
        }
    }

    func logMultiple(
        data: [ParraLogData]
    ) {
        eventQueue.async { [self] in
            for logData in data {
                logEventReceivedSync(
                    logData: logData
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
        logData: ParraLogData
    ) {
        guard logData.level >= loggerOptions.minimumLogLevel else {
            return
        }

        // At this point, the autoclosures passed to the logger functions are finally invoked.
        let processedLogData = ParraLogProcessedData(
            logData: logData
        )

        let wrappedEvent = ParraWrappedEvent.logEvent(
            event: ParraLogEvent(
                logData: processedLogData
            )
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
        if logData.logContext.bypassEventCreation {
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
            callSiteContext: logData.logContext.callSiteContext
        )
    }
}
