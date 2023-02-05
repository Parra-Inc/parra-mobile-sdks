//
//  Parra+Analytics.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate campaigns configured in the Parra dashboard.
    static func logAnalyticsEvent<Key>(_ name: ParraSessionNamedEvent,
                                       params: [Key: Any] = [String: Any]()) where Key: CustomStringConvertible {
        Task {
            await shared.sessionManager.logEvent(name.eventName, params: params)
        }
    }

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate campaigns configured in the Parra dashboard.
    static func logAnalyticsEvent<Key>(_ name: String,
                                       params: [Key: Any] = [String: Any]()) where Key: CustomStringConvertible {
        Task {
            await shared.sessionManager.logEvent(name, params: params)
        }
    }

    /// Logs a new event to the user's current session in Parra Analytics. Events can be used to activate campaigns configured in the Parra dashboard.
    static func logAnalyticsEvent<Name, Key>(_ name: Name,
                                             params: [Key: Any] = [String: Any]()) where Key: CustomStringConvertible, Name: RawRepresentable, Name.RawValue == String {
        Task {
            await shared.sessionManager.logEvent(name.rawValue, params: params)
        }
    }

    /// Attaches a property to the current user, as defined by the Parra authentication handler. User properties can be used to activate campaigns
    /// configured in the Parra dashboard.
    static func setUserProperty<Key>(_ value: Any,
                                     forKey key: Key) where Key: CustomStringConvertible {
        Task {
            await shared.sessionManager.setUserProperty(value, forKey: key)
        }
    }
}
