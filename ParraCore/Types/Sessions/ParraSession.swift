//
//  ParraSession.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

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
