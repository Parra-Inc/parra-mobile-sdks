//
//  ParraSessionManager.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal enum ParraSessionEventType: String {
    case impression
}

internal struct ParraSessionEvent: Codable {
    let eventId: String

    /// The type of the event. Event properties should be consistent for each event name
    let name: String

    /// The date the event occurred
    let createdAt: Date

    let metadata: [String: AnyCodable]
}

internal struct ParraSession: Codable {
    let sessionId: String
    let createdAt: Date
    private(set) var updatedAt: Date

    private(set) var events: [ParraSessionEvent]
    private(set) var userProperties: [String: AnyCodable]
    private(set) var hasNewData: Bool

    init() {
        let now = Date()

        self.sessionId = UUID().uuidString
        self.createdAt = now
        self.updatedAt = now
        self.events = []
        self.userProperties = [:]
        self.hasNewData = true
    }

    mutating func addEvent(_ event: ParraSessionEvent) {
        events.append(event)

        hasNewData = true
        updatedAt = Date()
    }

    mutating func updateUserProperties(_ newProperties: [String: AnyCodable]) {
        userProperties = newProperties

        hasNewData = true
        updatedAt = Date()
    }

    mutating func resetSentData() {
        hasNewData = false
        updatedAt = Date()
    }
}

internal actor ParraSessionManager: Syncable {
    private let dataManager: ParraDataManager
    private let networkManager: ParraNetworkManager

    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()

        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }()

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
