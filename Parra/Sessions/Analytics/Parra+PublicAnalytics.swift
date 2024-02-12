//
//  Parra+PublicAnalytics.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    // MARK: - Analytics Events

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
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

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
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

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
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

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
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

    // MARK: - User Properties

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    func setUserProperty(
        _ value: Any,
        forKey key: some CustomStringConvertible
    ) {
        setUserProperty(value, forKey: key.description)
    }

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    func setUserProperty<Key>(
        _ value: Any,
        forKey key: Key
    ) where Key: RawRepresentable, Key.RawValue == String {
        setUserProperty(value, forKey: key.rawValue)
    }

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    func setUserProperty(
        _ value: Any,
        forKey key: String
    ) {
        sessionManager.setUserProperty(value, forKey: key)
    }
}
