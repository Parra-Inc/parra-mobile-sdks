//
//  Parra+Analytics.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    // MARK: - Analytics Events

    /// Logs a new event to the user's current session in Parra Analytics.
    /// Events can be used to activate campaigns configured in the Parra
    /// dashboard.
    @inlinable
    func logEvent(
        _ event: ParraStandardEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        parraInternal.logEvent(event, extra, fileId, function, line, column)
    }

    /// Logs a new event to the user's current session in Parra Analytics.
    /// Events can be used to activate campaigns configured in the Parra
    /// dashboard.
    @inlinable
    func logEvent(
        _ event: ParraDataEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        parraInternal.logEvent(event, extra, fileId, function, line, column)
    }

    /// Logs a new event to the user's current session in Parra Analytics.
    /// Events can be used to activate campaigns configured in the Parra
    /// dashboard.
    @inlinable
    func logEvent(
        _ event: ParraEvent,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        parraInternal.logEvent(event, extra, fileId, function, line, column)
    }

    /// Logs a new event to the user's current session in Parra Analytics.
    /// Events can be used to activate campaigns configured in the Parra
    /// dashboard.
    @inlinable
    func logEvent(
        named eventName: String,
        _ extra: [String: Any]? = nil,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) {
        parraInternal.logEvent(
            named: eventName,
            extra,
            fileId,
            function,
            line,
            column
        )
    }

    // MARK: - User Properties

    /// Attaches a property to the current user, as defined by the Parra
    /// authentication handler. User properties can be used to activate
    /// campaigns configured in the Parra dashboard.
    func setUserProperty(
        _ value: Any,
        forKey key: some CustomStringConvertible
    ) {
        setUserProperty(value, forKey: key.description)
    }

    /// Attaches a property to the current user, as defined by the Parra
    /// authentication handler. User properties can be used to activate
    /// campaigns configured in the Parra dashboard.
    func setUserProperty<Key>(
        _ value: Any,
        forKey key: Key
    ) where Key: RawRepresentable, Key.RawValue == String {
        setUserProperty(value, forKey: key.rawValue)
    }

    /// Attaches a property to the current user, as defined by the Parra
    /// authentication handler. User properties can be used to activate
    /// campaigns configured in the Parra dashboard.
    func setUserProperty(
        _ value: Any,
        forKey key: String
    ) {
        parraInternal.setUserProperty(value, forKey: key)
    }
}
