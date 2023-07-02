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
    static func logEvent(
        _ event: ParraStandardEvent,
        params: [String: Any] = [:],
        fileId: String = #fileID
    ) {
        Task {
            await shared.sessionManager.log(
                event: ParraEventWrapper(event: event, extraParams: params),
                fileId: fileId
            )
        }
    }

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
    static func logEvent(
        _ event: ParraEvent,
        fileId: String = #fileID
    ) {
        Task {
            await shared.sessionManager.log(
                event: ParraEventWrapper(event: event),
                fileId: fileId
            )
        }
    }

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate
    /// campaigns configured in the Parra dashboard.
    static func logEvent(
        named eventName: String,
        params: [String: Any] = [:],
        fileId: String = #fileID
    ) {
        Task {
            await shared.sessionManager.log(
                event: ParraEventWrapper(name: eventName, params: params),
                fileId: fileId
            )
        }
    }

    // MARK: - User Properties

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    static func setUserProperty<Key>(
        _ value: Any,
        forKey key: Key
    ) where Key: CustomStringConvertible {
        setUserProperty(value, forKey: key.description)
    }

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    static func setUserProperty<Key>(
        _ value: Any,
        forKey key: Key
    ) where Key: RawRepresentable, Key.RawValue == String {
        setUserProperty(value, forKey: key.rawValue)
    }

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties
    /// can be used to activate campaigns configured in the Parra dashboard.
    static func setUserProperty(
        _ value: Any,
        forKey key: String
    ) {
        Task {
            await shared.sessionManager.setUserProperty(value, forKey: key)
        }
    }
}