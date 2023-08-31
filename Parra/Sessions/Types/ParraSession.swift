//
//  ParraSession.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSession: Codable {
    internal struct Constant {
        static let packageExtension = "parsesh"
    }

    internal let sessionId: String
    internal let createdAt: Date

    internal private(set) var endedAt: Date?
    internal private(set) var userProperties: [String : AnyCodable]

    /// The byte offset of the file handle responsible for writing the events associated with this session
    /// at the point where the last sync was initiated. This will be used to determine which events were
    /// written since the last sync, as well as deleting events in the current session that have already
    /// been synchronized.
    internal private(set) var eventsHandleOffsetAtSync: UInt64?

    internal var timestampId: String {
        return ParraSession.timestampId(from: createdAt)
    }

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

    internal func withUpdatedEventsHandleOffset(offset: UInt64) -> ParraSession {
        var updatedSession = self

        updatedSession.eventsHandleOffsetAtSync = offset

        return updatedSession
    }

    internal mutating func end() {
        self.endedAt = Date()
    }

    internal static func timestampId(from date: Date) -> String {
        return String(format: "%.0f", date.timeIntervalSince1970 * 1000000)
    }
}
