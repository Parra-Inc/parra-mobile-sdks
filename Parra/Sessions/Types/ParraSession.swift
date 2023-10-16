//
//  ParraSession.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSession: Codable, Equatable {
    internal struct Constant {
        static let packageExtension = "parsesh"
        static let erroredSessionPrefix = "_"
    }

    internal let sessionId: String
    internal let createdAt: Date

    internal private(set) var updatedAt: Date?
    internal private(set) var endedAt: Date?
    internal private(set) var userProperties: [String : AnyCodable]

    /// The byte offset of the file handle responsible for writing the events associated with this session
    /// at the point where the last sync was initiated. This will be used to determine which events were
    /// written since the last sync, as well as deleting events in the current session that have already
    /// been synchronized.
    internal private(set) var eventsHandleOffsetAtSync: UInt64?

    internal init(
        sessionId: String,
        createdAt: Date
    ) {
        self.sessionId = sessionId
        self.createdAt = createdAt
        self.updatedAt = nil
        self.endedAt = nil
        self.userProperties = [:]
    }

    internal func hasBeenUpdated(since date: Date?) -> Bool {
        guard let updatedAt else {
            // If updatedAt isn't set, it hasn't been updated since it was created.
            return false
        }

        guard let date else {
            return true
        }

        return updatedAt > date
    }

    // MARK: Performing Session Updates

    internal func withUpdates(
        handler: ((inout ParraSession) -> Void)? = nil
    ) -> ParraSession {
        var updatedSession = self

        handler?(&updatedSession)
        updatedSession.updatedAt = .now

        return updatedSession
    }

    internal func withUpdatedProperty(
        key: String,
        value: Any?
    ) -> ParraSession {
        return withUpdates { session in
            if let value {
                session.userProperties[key] = AnyCodable(value)
            } else {
                session.userProperties.removeValue(forKey: key)
            }
        }
    }

    internal func withUpdatedProperties(
        newProperties: [String : AnyCodable]
    ) -> ParraSession {
        return withUpdates { session in
            session.userProperties = newProperties
        }
    }

    internal func withUpdatedEventsHandleOffset(
        offset: UInt64
    ) -> ParraSession {
        return withUpdates { session in
            session.eventsHandleOffsetAtSync = offset
        }
    }
}
