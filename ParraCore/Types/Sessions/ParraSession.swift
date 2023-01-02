//
//  ParraSession.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraSession: Codable {
    public let sessionId: String
    public let createdAt: Date
    public private(set) var updatedAt: Date

    public private(set) var events: [ParraSessionEvent]
    public private(set) var userProperties: [String: AnyCodable]
    public private(set) var hasNewData: Bool

    internal init() {
        let now = Date()

        self.sessionId = UUID().uuidString
        self.createdAt = now
        self.updatedAt = now
        self.events = []
        self.userProperties = [:]
        self.hasNewData = true
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
}
