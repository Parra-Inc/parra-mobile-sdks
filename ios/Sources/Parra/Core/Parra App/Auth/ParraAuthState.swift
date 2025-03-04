//
//  ParraAuthState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraAuthState: Equatable, CustomStringConvertible {
    case authenticated(ParraUser) // unauthenticated == any other case
    case anonymous(ParraUser)
    /// Only available when anonymous auth is disabled for the tenant.
    case guest(ParraGuest) // no sessions
    case undetermined

    // MARK: - Public

    public var user: ParraUser? {
        switch self {
        case .authenticated(let user), .anonymous(let user):
            return user
        case .guest, .undetermined:
            return nil
        }
    }

    /// Whether the user is fully logged in via an authentication method like
    /// email, phone, passkeys, etc. This does not include anonymous auth.
    public var isLoggedIn: Bool {
        switch self {
        case .authenticated:
            return true
        default:
            return false
        }
    }

    /// Whether the user is using guest auth.
    public var isGuest: Bool {
        switch self {
        case .guest:
            return true
        default:
            return false
        }
    }

    /// Whether there is a user object associated with this user. This includes
    /// users using anonymous auth and users who are fully logged in.
    public var hasUser: Bool {
        switch self {
        case .authenticated, .anonymous:
            return true
        default:
            return false
        }
    }

    /// The user has been issued a token and can interact with the Parra API in
    /// some capacity. This includes fully authenticated, anonymous and guest
    /// users.
    public var hasToken: Bool {
        switch self {
        case .authenticated, .anonymous, .guest:
            return true
        default:
            return false
        }
    }

    public var description: String {
        switch self {
        case .undetermined:
            return "undetermined"
        case .authenticated:
            return "authenticated"
        case .anonymous:
            return "anonymous"
        case .guest:
            return "guest"
        }
    }

    public static func == (
        lhs: ParraAuthState,
        rhs: ParraAuthState
    ) -> Bool {
        switch (lhs, rhs) {
        case (.undetermined, .undetermined):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser == rhsUser
        case (.anonymous(let lhsUser), .anonymous(let rhsUser)):
            return lhsUser == rhsUser
        case (.guest(let lhsUser), .guest(let rhsUser)):
            return lhsUser == rhsUser
        default:
            return false
        }
    }

    public func userHasRole(
        with key: String
    ) -> Bool {
        guard let user else {
            return false
        }

        guard let roles = user.info.roles?.elements else {
            return false
        }

        return roles.contains { role in
            return role.key == key
        }
    }

    // MARK: - Internal

    var hasResolvedAuth: Bool {
        switch self {
        case .authenticated, .anonymous, .guest:
            return true
        default:
            return false
        }
    }

    var credential: ParraUser.Credential? {
        switch self {
        case .authenticated(let user), .anonymous(let user):
            return user.credential
        case .guest(let guest):
            return guest.credential
        case .undetermined:
            return nil
        }
    }
}
