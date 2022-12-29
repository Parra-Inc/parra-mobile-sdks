//
//  Parra+Analytics.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - params: <#params description#>
    static func logAnalyticsEvent<Key>(_ name: String,
                                       params: [Key: Any]) where Key: CustomStringConvertible {
        Task {
            await shared.sessionManager.logEvent(name, params: params)
        }
    }

    static func logAnalyticsEvent<Name, Key>(_ name: Name,
                                             params: [Key: Any]) where Key: CustomStringConvertible, Name: RawRepresentable, Name.RawValue == String {
        Task {
            await shared.sessionManager.logEvent(name.rawValue, params: params)
        }
    }

    /// <#Description#>
    /// - Parameters:
    ///   - value: <#value description#>
    ///   - key: <#key description#>
    static func setUserProperty<Key>(_ value: Any,
                                     forKey key: Key) where Key: CustomStringConvertible {
        Task {
            await shared.sessionManager.setUserProperty(value, forKey: key)
        }
    }
}
