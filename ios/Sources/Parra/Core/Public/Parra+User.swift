//
//  Parra+User.swift
//  Parra
//
//  Created by Mick MacCallum on 10/3/24.
//

import Foundation

public extension Parra {
    /// The currently logged in user, if one exists. It is preferrable to access
    /// auth state via the `parraAuthState` environment value, which will allow
    /// for subscription to auth state changes. Use this in cases where you need
    /// read-only access to the user object from outside of SwiftUI.
    static var currentUser: ParraUser? {
        return `default`.parraInternal.authService._cachedAuthState?.user
    }
}
