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

fileprivate let logger = Logger(category: "Session manager")

// Needs
// 1. Logging events without waiting.
// 2. Thread safe state to know if there is pending sync data
// 3. Ability to wait on writes to finish when logging if desired
// 4. Open file handle when session starts
// 5. Log events to memory as soon as their written
// 6. Events are written to disk in batches
// 7. Certain high priority events trigger a write immediately

/// ParraSessionManager
internal class ParraSessionManager: ParraLoggerBackend {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager
    private var loggerOptions: ParraLoggerOptions

    internal private(set) var currentSession: ParraSession?

    private var userProperties: [String: AnyCodable] = [:]

    fileprivate let eventQueue = DispatchQueue(
        label: "com.parra.sessions.event-queue",
        qos: .utility
    )

    internal init(
        dataManager: ParraDataManager,
        networkManager: ParraNetworkManager,
        loggerOptions: ParraLoggerOptions
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.loggerOptions = loggerOptions
        self.currentSession = ParraSession()
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

    internal func hasDataToSync() async -> Bool {
        let persistedSessionCount = await dataManager.sessionStorage.numberOfTrackedSessions()
        // Sync if there are any sessions that aren't still in progress, or if the session
        // in progress has new events to report.

        if persistedSessionCount > 1 {
            return true
        }

        return currentSession?.hasNewData ?? false
    }

    func clearSessionHistory() async {
        logger.debug("Clearing previous session history")

        let allSessions = await dataManager.sessionStorage.allTrackedSessions()
        let sessionIds = allSessions.reduce(Set<String>()) { partialResult, session in
            var next = partialResult
            next.insert(session.sessionId)
            return next
        }

        await dataManager.sessionStorage.deleteSessions(
            with: sessionIds
        )
    }

    func synchronizeData() async -> ParraSessionsResponse? {
        guard var currentSession else {
            return nil
        }

        // Reset and update the cache for the current session so the most up to take data is uploaded.
        currentSession.resetSentData()
        await dataManager.sessionStorage.update(
            session: currentSession
        )

        let sessions = await dataManager.sessionStorage.allTrackedSessions()

        var sessionResponse: ParraSessionsResponse?
        do {
            let (completedSessionIds, nextSessionResponse) = try await networkManager.bulkSubmitSessions(
                sessions: sessions
            )

            sessionResponse = nextSessionResponse

            // Remove all of the successfully uploaded sessions except for the
            // session that is in progress.
            await dataManager.sessionStorage.deleteSessions(
                with: completedSessionIds.subtracting([currentSession.sessionId])
            )
        } catch let error {
            logger.error("Syncing sessions failed", error)
        }

        self.currentSession = currentSession

        return sessionResponse
    }

    internal func log(data: ParraLogData) {
        eventQueue.async { [self] in
            logEventReceived(logData: data)
        }
    }

    internal func logMultiple(data: [ParraLogData]) {
        eventQueue.async { [self] in
            for logData in data {
                logEventReceived(logData: logData)
            }
        }
    }

    private func logEventReceived(
        logData: ParraLogData
    ) {
        guard logData.level >= loggerOptions.minimumLogLevel else {
            return
        }

        // At this point, the autoclosures passed to the logger functions are finally invoked.
        let processedLogData = ParraLogProcessedData(
            logData: logData
        )

        writeEventSync(
            wrappedEvent: .internalEvent(
                event: .log(logData: processedLogData)
            ),
            // Special case. Call site context is that of the origin of the log.
            callSiteContext: logData.callSiteContext
        )
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
        // TODO: Event logging should take the same env flag that the logger looks at into consideration.
        // TODO: Need to ditch the Task and async/await here and process synchronously on the event queue.

        Task {
            await createSessionIfNotExists()

            guard var currentSession else {
                return
            }

            let sessionEvent = ParraSessionEvent(
                wrappedEvent: wrappedEvent,
                callSiteContext: callSiteContext
            )

            currentSession.updateUserProperties(userProperties)
            currentSession.addEvent(sessionEvent)

            await dataManager.sessionStorage.update(
                session: currentSession
            )

            self.currentSession = currentSession

            if loggerOptions.environment.hasDebugBehavior {
                writeEventToConsole(
                    wrappedEvent: wrappedEvent,
                    with: loggerOptions.consoleFormatOptions
                )
            }
        }
    }

    internal func setUserProperty(
        _ value: Any?,
        forKey key: String
    ) async {
        await createSessionIfNotExists()

        guard var currentSession else {
            return
        }

        #if DEBUG
        logger.debug("Updating user property", [
            "key": key,
            "new value": String(describing: value),
            "old value": String(describing: self.userProperties[key])
        ])
        #endif

        if let value {
            userProperties[key] = .init(value)
        } else {
            userProperties.removeValue(forKey: key)
        }

        currentSession.updateUserProperties(userProperties)

        await dataManager.sessionStorage.update(
            session: currentSession
        )

        self.currentSession = currentSession
    }

    internal func resetSession() async {
        guard var currentSession else {
            return
        }

        currentSession.end()
        currentSession.resetSentData()

        await dataManager.sessionStorage.update(
            session: currentSession
        )

        self.currentSession = nil
    }

    internal func endSession() async {
        guard var currentSession else {
            return
        }

        currentSession.end()

        await dataManager.sessionStorage.update(
            session: currentSession
        )

        self.currentSession = nil
    }

    internal func createSessionIfNotExists() async {
        guard currentSession == nil else {
            return
        }

        logger.debug("No session exists. Starting new session.")


        var currentSession = ParraSession()

        currentSession.updateUserProperties(userProperties)

        await dataManager.sessionStorage.update(
            session: currentSession
        )

        self.currentSession = currentSession
    }
}
