//
//  ParraSessionEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// Contains ``ParraEvent`` data suitable for storage within a session.
struct ParraSessionEvent: Codable {
    // MARK: - Lifecycle

    init(
        createdAt: Date,
        name: String,
        metadata: AnyCodable
    ) {
        self.createdAt = createdAt
        self.name = name
        self.metadata = metadata
    }

    // MARK: - Internal

    let createdAt: Date
    let name: String

    // Stop thinking this can be renamed. There is a server-side validation on this field name.
    let metadata: AnyCodable

    static func normalizedEventData(
        from wrappedEvent: ParraWrappedEvent
    ) -> (name: String, extra: [String: Any]) {
        let name: String
        let combinedExtra: [String: Any]

        switch wrappedEvent {
        case .event(let event, let extra):
            name = event.name

            if let extra {
                combinedExtra = extra
            } else {
                combinedExtra = [:]
            }
        case .dataEvent(let event, let extra):
            name = event.name

            if let extra {
                combinedExtra = event.extra.merging(extra) { $1 }
            } else {
                combinedExtra = event.extra
            }
        case .internalEvent(let event, let extra):
            name = event.displayName

            var merged = if let extra {
                event.extra.merging(extra) { $1 }
            } else {
                event.extra
            }

            merged["name"] = event.name

            combinedExtra = merged
        case .logEvent(let event):
            name = event.name
            combinedExtra = event.extra
        }

        return (name, combinedExtra)
    }

    static func normalizedEventContextData(
        from wrappedEvent: ParraWrappedEvent
    )
        -> (
            isClientGenerated: Bool,
            syncPriority: ParraSessionEventSyncPriority
        )
    {
        guard case .logEvent(let event) = wrappedEvent else {
            return (false, .low)
        }

        // It's possible that this will need to be updated to be more clever in the future
        // but for now, we consider an event to be generated from within Parra if the
        // current module at the call site is the name of the Parra module.
        let isClientGenerated = !LoggerHelpers.isFileIdInternal(
            fileId: event.logData.callSiteContext.fileId
        )

        let level = event.logData.level

        let syncPriority: ParraSessionEventSyncPriority = if case .error =
            level
        {
            .high
        } else if case .fatal = level {
            .critical
        } else {
            .low
        }

        return (isClientGenerated, syncPriority)
    }

    static func sessionEventFromEventWrapper(
        wrappedEvent: ParraWrappedEvent,
        callSiteContext: ParraLoggerCallSiteContext
    ) -> (
        event: ParraSessionEvent,
        context: ParraSessionEventContext
    ) {
        let (name, combinedExtra) = normalizedEventData(from: wrappedEvent)
        let (
            isClientGenerated,
            syncPriority
        ) = normalizedEventContextData(from: wrappedEvent)

        return (
            event: ParraSessionEvent(
                createdAt: .now,
                name: StringManipulators.snakeCaseify(
                    text: name
                ),
                metadata: AnyCodable(combinedExtra)
            ),
            context: ParraSessionEventContext(
                isClientGenerated: isClientGenerated,
                syncPriority: syncPriority
            )
        )
    }
}
