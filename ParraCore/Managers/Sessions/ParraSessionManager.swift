//
//  ParraSessionManager.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal actor ParraSessionManager: Syncable {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager
    private var currentSession = ParraSession()
    private var userProperties: [String: AnyCodable] = [:]

    internal init(dataManager: ParraDataManager,
                  networkManager: ParraNetworkManager) {

        self.dataManager = dataManager
        self.networkManager = networkManager
    }

    func hasDataToSync() async -> Bool {
        let persistedSessionCount = await dataManager.sessionStorage.numberOfTrackedSessions()

        // Sync if there are any sessions that aren't still in progress, or if the session
        // in progress has new events to report.
        return currentSession.hasNewData || persistedSessionCount > 0
    }

    func triggerSync() async {
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
            parraLogE("Syncing sessions failed", error)
        }
    }

    internal func logEvent<Key>(_ name: String,
                                params: [Key: Any]) async where Key: CustomStringConvertible {

        let metadata: [String: AnyCodable] = Dictionary(uniqueKeysWithValues:
                                    params.map { key, value in
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
    }

    internal func setUserProperty<Key>(_ value: Any?,
                                       forKey key: Key) async where Key: CustomStringConvertible {
        if let value {
            userProperties[key.description] = .init(value)
        } else {
            userProperties.removeValue(forKey: key.description)
        }

        currentSession.updateUserProperties(userProperties)

        await dataManager.sessionStorage.update(session: currentSession)
    }
}