//
//  ParraSession.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSessionUpload: Encodable {
    let session: ParraSession

    internal enum CodingKeys: String, CodingKey {
        case events
        case userProperties
        case startedAt
        case endedAt
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.session.events, forKey: .events)
        try container.encode(self.session.userProperties, forKey: .userProperties)
        try container.encode(self.session.createdAt, forKey: .startedAt)
        try container.encode(self.session.endedAt, forKey: .endedAt)
    }
}

internal struct ParraSession: Codable {
    internal let sessionId: String
    internal let createdAt: Date
    internal private(set) var updatedAt: Date
    internal private(set) var endedAt: Date?

    internal private(set) var events: [ParraSessionEvent]
    internal private(set) var userProperties: [String : AnyCodable]
    internal private(set) var hasNewData: Bool

    internal init() {
        let now = Date()

        self.sessionId = UUID().uuidString
        self.createdAt = now
        self.updatedAt = now
        self.endedAt = nil
        self.events = []
        self.userProperties = [:]
        self.hasNewData = false
    }

    internal mutating func addEvent(_ event: ParraSessionEvent) {
        events.append(event)

        hasNewData = true
        updatedAt = Date()
    }

    internal mutating func updateUserProperties(_ newProperties: [String : AnyCodable]) {
        userProperties = newProperties

        hasNewData = true
        updatedAt = Date()
    }

    internal mutating func resetSentData() {
        hasNewData = false
        updatedAt = Date()
    }

    internal mutating func end() {
        self.hasNewData = true
        self.endedAt = Date()
    }
}
