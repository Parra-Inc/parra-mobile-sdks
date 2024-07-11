//
//  ParraSession.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraSession: Codable, Equatable {
    // MARK: - Lifecycle

    init(
        sessionId: String,
        createdAt: Date,
        sdkVersion: String
    ) {
        self.sessionId = sessionId
        self.createdAt = createdAt
        self.sdkVersion = sdkVersion
        self.updatedAt = nil
        self.endedAt = nil
        self.userProperties = [:]
    }

    // MARK: - Internal

    enum Constant {
        static let packageExtension = "parsesh"
        static let erroredSessionPrefix = "_"
    }

    let sessionId: String
    /// The SDK version at the time of session creation. Stored to handle cases where a session is created
    /// and written to disk, then eventually loaded after an app update installs a newer version of the SDK.
    let sdkVersion: String
    let createdAt: Date

    private(set) var updatedAt: Date?
    private(set) var endedAt: Date?
    private(set) var userProperties: [String: AnyCodable]

    /// The byte offset of the file handle responsible for writing the events associated with this session
    /// at the point where the last sync was initiated. This will be used to determine which events were
    /// written since the last sync, as well as deleting events in the current session that have already
    /// been synchronized.
    private(set) var eventsHandleOffsetAtSync: UInt64?

    mutating func end(at date: Date) {
        updatedAt = date
        endedAt = date
    }

    func hasBeenUpdated(since date: Date?) -> Bool {
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

    func withUpdates(
        handler: ((inout ParraSession) -> Void)? = nil
    ) -> ParraSession {
        var updatedSession = self

        handler?(&updatedSession)
        updatedSession.updatedAt = .now

        return updatedSession
    }

    func withUpdatedProperty(
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

    func withUpdatedProperties(
        newProperties: [String: AnyCodable]
    ) -> ParraSession {
        return withUpdates { session in
            session.userProperties = newProperties
        }
    }

    func withUpdatedEventsHandleOffset(
        offset: UInt64
    ) -> ParraSession {
        return withUpdates { session in
            session.eventsHandleOffsetAtSync = offset
        }
    }
}
