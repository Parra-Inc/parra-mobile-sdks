//
//  ParraSession.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraSessionUpload: Encodable {
    let session: ParraSession

    public enum CodingKeys: String, CodingKey {
        case events
        case userProperties
        case createdAt
        case endedAt
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.session.events, forKey: .events)
        try container.encode(self.session.userProperties, forKey: .userProperties)
        try container.encode(self.session.createdAt, forKey: .createdAt)
        try container.encode(self.session.endedAt, forKey: .endedAt)
    }
}

public struct ParraSession: Codable {
    public let sessionId: String
    public let createdAt: Date
    public private(set) var updatedAt: Date
    public private(set) var endedAt: Date?

    public private(set) var events: [ParraSessionEvent]
    public private(set) var userProperties: [String: AnyCodable]
    public private(set) var hasNewData: Bool

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

    internal mutating func updateUserProperties(_ newProperties: [String: AnyCodable]) {
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
