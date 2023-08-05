//
//  ParraSessionEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// Contains ``ParraEvent`` data suitable for storage within a session.
internal struct ParraSessionEvent: Codable {
    internal let createdAt: Date
    internal let name: String
    internal let payload: AnyCodable

    internal init(
        createdAt: Date = .now,
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let (module, file) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        let name: String
        var payload: [String : Any] = [
            "metadata": [
                "module": module,
                "file": file
            ]
        ]

        switch wrappedEvent {
        case .event(let event, let extra):
            name = event.name

            if let extra {
                payload.merge(extra) { $1 }
            }
        case .dataEvent(let event, let extra):
            name = event.name

            if let extra {
                payload.merge(event.extra.merging(extra) { $1 }) { $1 }
            } else {
                payload.merge(event.extra) { $1 }
            }
        case .internalEvent(let event, let extra):
            name = event.name

            if let extra {
                payload.merge(event.extra.merging(extra) { $1 }) { $1 }
            } else {
                payload.merge(event.extra) { $1 }
            }
        }

        self.name = StringManipulators.snakeCaseify(text: name)
        self.createdAt = createdAt
        self.payload = AnyCodable.init(payload)
    }
}

