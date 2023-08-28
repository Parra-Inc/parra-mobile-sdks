//
//  ParraSession.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSession: Codable {
    internal let sessionId: String
    internal let createdAt: Date
    internal private(set) var endedAt: Date?

    internal private(set) var userProperties: [String : AnyCodable]

    internal init(createdAt: Date) {
        self.sessionId = UUID().uuidString
        self.createdAt = createdAt
        self.endedAt = nil
        self.userProperties = [:]
    }

    internal func withUpdatedProperty(
        key: String,
        value: Any?
    ) -> ParraSession {
        var updatedSession = self

        if let value {
            updatedSession.userProperties[key] = AnyCodable(value)
        } else {
            updatedSession.userProperties.removeValue(forKey: key)
        }

        return updatedSession
    }

    internal func withUpdatedProperties(newProperties: [String : AnyCodable]) -> ParraSession {
        var updatedSession = self

        updatedSession.userProperties = newProperties

        return updatedSession
    }

    internal mutating func end() {
        self.endedAt = Date()
    }
}
