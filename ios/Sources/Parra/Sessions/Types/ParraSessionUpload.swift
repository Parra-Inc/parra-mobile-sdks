//
//  ParraSessionUpload.swift
//  Parra
//
//  Created by Mick MacCallum on 8/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// Events for a session are stored seperately and must be put together with the
/// session object before uploading it.
struct ParraSessionUpload: Encodable {
    enum CodingKeys: String, CodingKey {
        case events
        case userProperties
        case startedAt
        case endedAt
        case chunkIndex
    }

    let session: ParraSession
    let events: [ParraSessionEvent]
    let chunkIndex: Int

    init(
        session: ParraSession,
        events: [ParraSessionEvent] = [],
        chunkIndex: Int = 0
    ) {
        self.session = session
        self.events = events
        self.chunkIndex = chunkIndex
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(events, forKey: .events)
        try container.encode(session.userProperties, forKey: .userProperties)
        try container.encode(session.createdAt, forKey: .startedAt)
        try container.encode(session.endedAt, forKey: .endedAt)
        try container.encode(chunkIndex, forKey: .chunkIndex)
    }

    func withChunkedEvents(
        newEvents: [ParraSessionEvent],
        chunkIndex: Int
    ) -> ParraSessionUpload {
        return ParraSessionUpload(
            session: session,
            events: newEvents,
            chunkIndex: chunkIndex
        )
    }
}
