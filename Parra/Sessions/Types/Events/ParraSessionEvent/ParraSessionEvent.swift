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
        createdAt: Date,
        name: String,
        metadata: AnyCodable
    ) {
        self.createdAt = createdAt
        self.name = name
        self.metadata = metadata
    }

    internal static func sessionEventFromEventWrapper(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) -> (
        event: ParraSessionEvent,
        context: ParraSessionEventContext
    ) {
        let name: String
        var combinedExtra: [String : Any] = [:]

        var isClientGenerated = false
        var syncPriority: ParraSessionEventSyncPriority = .low

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
        case .logEvent(let event):
            name = event.name
            combinedExtra.merge(event.extra) { $1 }

            // It's possible that this will need to be updated to be more clever in the future
            // but for now, we consider an event to be generated from within Parra if the
            // current module at the call site is the name of the Parra module.
            isClientGenerated = !LoggerHelpers.isFileIdInternal(
                fileId: event.logData.callSiteContext.fileId
            )

            let level = event.logData.level
            if case .error = level {
                syncPriority = .high
            } else if case .fatal = level {
                syncPriority = .critical
            }
        }

        return (
            event: ParraSessionEvent(
                createdAt: .now,
                name: StringManipulators.snakeCaseify(
                    text: name
                ),
                metadata: AnyCodable.init(combinedExtra)
            ),
            context: ParraSessionEventContext(
                isClientGenerated: isClientGenerated,
                syncPriority: syncPriority
            )
        )
    }
}

