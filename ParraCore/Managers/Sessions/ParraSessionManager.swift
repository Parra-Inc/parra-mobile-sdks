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
        return currentSession.hasNewData
    }

    func triggerSync() async {
        currentSession.resetSentData()
    }

    internal func logEvent<Key>(_ name: String,
                                params: [Key: Any]) async where Key: CustomStringConvertible {

        let metadata: [String: AnyCodable] = Dictionary(uniqueKeysWithValues:
                                    params.map { key, value in
            (key.description, .init(value))
        })

        let newEvent = ParraSessionEvent(
            eventId: UUID().uuidString,
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
