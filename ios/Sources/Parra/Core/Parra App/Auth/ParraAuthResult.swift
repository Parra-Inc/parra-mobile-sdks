//
//  ParraAuthResult.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraAuthResult: Equatable, CustomStringConvertible {
    case authenticated(ParraUser) // unauthenticated == any other case
    case anonymous(ParraUser)
    /// Only available when anonymous auth is disabled for the tenant.
    case guest(ParraGuest) // no sessions
    case error(Error)
    case undetermined

    public var isLoggedIn: Bool {
        switch self {
        case .authenticated:
            return true
        default:
            return false
        }
    }

    public var hasUser: Bool {
        switch self {
        case .authenticated, .anonymous:
            return true
        default:
            return false
        }
    }

    public var hasToken: Bool {
        switch self {
        case .authenticated, .anonymous, .guest:
            return true
        default:
            return false
        }
    }

    public var hasResolvedAuth: Bool {
        switch self {
        case .authenticated, .anonymous, .guest, .error:
            return true
        default:
            return false
        }
    }

    // MARK: - Public

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
        case .error:
            return "unauthenticated with error"
        }
    }

    public static func == (
        lhs: ParraAuthResult,
        rhs: ParraAuthResult
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
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError
                .localizedDescription
        default:
            return false
        }
    }
}
