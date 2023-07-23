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
    internal let extra: AnyCodable

    internal init(
        createdAt: Date = .now,
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) {
        let (module, file) = LoggerHelpers.splitFileId(
            fileId: callSiteContext.fileId
        )

        let name: String
        var mergedExtra: [String: Any] = [
            "metadata": [
                "module": module,
                "file": file
            ]
        ]

        switch wrappedEvent {
        case .event(let event, let extra):
            name = event.name

            if let extra {
                mergedExtra["extra"] = extra
            }
        case .dataEvent(let event, let extra):
            name = event.name

            if let extra {
                mergedExtra["extra"] = event.extra.merging(extra) { $1 }
            } else {
                mergedExtra["extra"] = event.extra
            }
        case .internalEvent(let event, let extra):
            name = event.name

            if let extra {
                mergedExtra["extra"] = event.extra.merging(extra) { $1 }
            } else {
                mergedExtra["extra"] = event.extra
            }
        }

        self.name = StringManipulators.snakeCaseify(text: name)
        self.createdAt = createdAt
        self.extra = AnyCodable.init(mergedExtra)
    }
}

