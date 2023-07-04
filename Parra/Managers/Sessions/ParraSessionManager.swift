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

/// ParraSessionManager
internal actor ParraSessionManager {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager

    internal private(set) var currentSession: ParraSession?

    private var userProperties: [String: AnyCodable] = [:]

    internal init(
        dataManager: ParraDataManager,
        networkManager: ParraNetworkManager
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.currentSession = ParraSession()
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
        parraLogDebug("Clearing previous session history")

        let allSessions = await dataManager.sessionStorage.allTrackedSessions()
        let sessionIds = allSessions.reduce(Set<String>()) { partialResult, session in
            var next = partialResult
            next.insert(session.sessionId)
            return next
        }

        await dataManager.sessionStorage.deleteSessions(with: sessionIds)
    }

    func synchronizeData() async -> ParraSessionsResponse? {
        guard var currentSession else {
            return nil
        }

        // Reset and update the cache for the current session so the most up to take data is uploaded.
        currentSession.resetSentData()
        await dataManager.sessionStorage.update(session: currentSession)

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
            parraLogError("Syncing sessions failed", error)
        }

        self.currentSession = currentSession

        return sessionResponse
    }

    /// Logs the supplied event on the user's session.
    /// Do not interact with this method directly. Logging events should be done through the
    /// Parra.logEvent helpers.
    internal func log(
        event: ParraEventWrapper,
        fileId: String = #fileID
    ) async {
        let (module, file) = LoggerHelpers.splitFileId(fileId: fileId)

        await createSessionIfNotExists()
        
        guard var currentSession else {
            return
        }

        #if DEBUG
        // !Very important! There is a similar condition inside the logger to send log events
        // to the session manager when NOT in DEBUG builds. Removing this condition will result
        // in infinite recursion.
        parraLogDebug(event.name, event.params)
        #endif

        let newEvent = ParraSessionEvent(
            name: event.name,
            createdAt: .now,
            metadata: [
                "origin": [
                    "module": module,
                    "file": file
                ],
                "params": AnyCodable.init(event.params)
            ]
        )

        currentSession.updateUserProperties(userProperties)
        currentSession.addEvent(newEvent)

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = currentSession
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
        parraLogDebug("Updating user property", [
            "key": key,
            "new value": String(describing: value),
            "old value": String(describing: userProperties[key])
        ])
        #endif

        if let value {
            userProperties[key] = .init(value)
        } else {
            userProperties.removeValue(forKey: key)
        }

        currentSession.updateUserProperties(userProperties)

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = currentSession
    }

    internal func resetSession() async {
        guard var currentSession else {
            return
        }

        currentSession.end()
        currentSession.resetSentData()

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = nil
    }

    internal func endSession() async {
        guard var currentSession else {
            return
        }

        currentSession.end()

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = nil
    }

    internal func createSessionIfNotExists() async {
        guard currentSession == nil else {
            return
        }

        parraLogDebug("No session exists. Starting new session.")


        var currentSession = ParraSession()

        currentSession.updateUserProperties(userProperties)

        // TODO: Instead of logging events for things like app state when session is first created
        // TODO: Add a new session property deviceProperties, which can be updated whenever a event is logged.
        // TODO: Best way to do this is probably to make an event to log called devicePropertiesChanged that
        // TODO: contains all of the changed properties.

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = currentSession
    }
}
