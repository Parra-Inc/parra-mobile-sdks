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

    internal init() {
        let now = Date()

        self.sessionId = UUID().uuidString
        self.createdAt = now
        self.endedAt = nil
        self.userProperties = [:]
    }

    internal mutating func updateUserProperties(
        _ newProperties: [String : AnyCodable]
    ) {
        userProperties = newProperties
    }

    internal mutating func end() {
        self.endedAt = Date()
    }
}
