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
    // Stop thinking this can be renamed. There is a server-side validation on this field name.
    internal let metadata: AnyCodable

    internal init(
        createdAt: Date = .now,
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let (module, file) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        let name: String
        var combinedExtra: [String : Any] = [
            "metadata": [
                "module": module,
                "file": file
            ]
        ]

        switch wrappedEvent {
        case .event(let event, let extra):
            name = event.name

            if let extra {
                combinedExtra.merge(extra) { $1 }
            }
        case .dataEvent(let event, let extra):
            name = event.name

            if let extra {
                combinedExtra.merge(event.extra.merging(extra) { $1 }) { $1 }
            } else {
                combinedExtra.merge(event.extra) { $1 }
            }
        case .internalEvent(let event, let extra):
            name = event.name

            if let extra {
                combinedExtra.merge(event.extra.merging(extra) { $1 }) { $1 }
            } else {
                combinedExtra.merge(event.extra) { $1 }
            }
        }

        self.name = StringManipulators.snakeCaseify(text: name)
        self.createdAt = createdAt
        self.metadata = AnyCodable.init(combinedExtra)
    }
}

