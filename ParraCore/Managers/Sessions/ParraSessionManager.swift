//
//  ParraSessionManager.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

/// ParraSessionManager
/// Session Lifecycle
///
internal actor ParraSessionManager: Syncable {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager
    private var currentSession: ParraSession?
    private var userProperties: [String: AnyCodable] = [:]

    internal init(dataManager: ParraDataManager,
                  networkManager: ParraNetworkManager) {

        self.dataManager = dataManager
        self.networkManager = networkManager
        self.currentSession = ParraSession()
    }

    func hasDataToSync() async -> Bool {
        let persistedSessionCount = await dataManager.sessionStorage.numberOfTrackedSessions()
        // Sync if there are any sessions that aren't still in progress, or if the session
        // in progress has new events to report.

        if persistedSessionCount > 1 {
            return true
        }

        return currentSession?.hasNewData ?? false
    }

    func synchronizeData() async {
        guard var currentSession else {
            return
        }

        // Reset and update the cache for the current session so the most up to take data is uploaded.
        currentSession.resetSentData()
        await dataManager.sessionStorage.update(session: currentSession)

        let sessions = await dataManager.sessionStorage.allTrackedSessions()

        do {
            let completedSessionIds = try await Parra.Sessions.bulkSubmitSessions(
                sessions: sessions
            )

            // Remove all of the successfully uploaded sessions except for the
            // session that is in progress.
            await dataManager.sessionStorage.deleteSessions(
                with: completedSessionIds.subtracting([currentSession.sessionId])
            )
        } catch let error {
            parraLogError("Syncing sessions failed", error)
        }

        self.currentSession = currentSession
    }

    internal func logEvent<Key>(_ name: String,
                                params: [Key: Any]) async where Key: CustomStringConvertible {

        await createSessionIfNotExists()

        guard var currentSession else {
            return
        }

        let metadata: [String: AnyCodable] = Dictionary(
            uniqueKeysWithValues: params.map { key, value in
                (key.description, .init(value))
            })

        let newEvent = ParraSessionEvent(
            name: name,
            createdAt: Date(),
            metadata: metadata
        )

        currentSession.updateUserProperties(userProperties)
        currentSession.addEvent(newEvent)

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = currentSession
    }

    internal func setUserProperty<Key>(_ value: Any?,
                                       forKey key: Key) async where Key: CustomStringConvertible {

        await createSessionIfNotExists()

        guard var currentSession else {
            return
        }

        if let value {
            userProperties[key.description] = .init(value)
        } else {
            userProperties.removeValue(forKey: key.description)
        }

        currentSession.updateUserProperties(userProperties)

        await dataManager.sessionStorage.update(session: currentSession)

        self.currentSession = currentSession
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
            parraLogDebug("Session is already in progress. Skipping creating new one.")

            return
        }

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
