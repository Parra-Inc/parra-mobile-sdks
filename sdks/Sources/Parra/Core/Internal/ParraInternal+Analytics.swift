//
//  ParraInternal+Analytics.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    @inlinable
    func logEvent(
        _ event: ParraInternalEvent,
        _ extra: [String: Any],
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .internalEvent(
                event: event,
                extra: extra
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        _ event: ParraInternalEvent,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .internalEvent(
                event: event,
                extra: nil
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        _ event: ParraStandardEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .dataEvent(event: event, extra: extra),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        _ event: ParraDataEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .dataEvent(event: event, extra: extra),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        _ event: ParraEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        sessionManager.writeEvent(
            wrappedEvent: .event(event: event, extra: extra),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    @inlinable
    func logEvent(
        named eventName: String,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        let wrappedEvent: ParraWrappedEvent = if let extra, !extra.isEmpty {
            .dataEvent(
                event: ParraBasicDataEvent(
                    name: eventName,
                    extra: extra
                )
            )
        } else {
            .event(
                event: ParraBasicEvent(
                    name: eventName
                )
            )
        }

        sessionManager.writeEvent(
            wrappedEvent: wrappedEvent,
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )
    }

    func setUserProperty(
        _ value: Any,
        forKey key: String
    ) {
        sessionManager.setUserProperty(value, forKey: key)
    }
}
