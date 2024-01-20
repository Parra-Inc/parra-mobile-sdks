//
//  ParraSessionUpload.swift
//  Parra
//
//  Created by Mick MacCallum on 8/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// Events for a session are stored seperately and must be put together with the session
/// object before uploading it.
internal struct ParraSessionUpload: Encodable {
    let session: ParraSession
    let events: [ParraSessionEvent]

    internal enum CodingKeys: String, CodingKey {
        case events
        case userProperties
        case startedAt
        case endedAt
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(events, forKey: .events)
        try container.encode(session.userProperties, forKey: .userProperties)
        try container.encode(session.createdAt, forKey: .startedAt)
        try container.encode(session.endedAt, forKey: .endedAt)
    }
}
