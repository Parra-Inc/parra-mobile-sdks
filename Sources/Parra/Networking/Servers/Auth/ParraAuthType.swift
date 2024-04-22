//
//  ParraAuthType.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraTokenProvider = () async throws -> String?
public typealias ParraUserIdProvider = () async throws -> String?

public enum ParraAuthType {
    /// The standard way of authenticating with Parra. You provide a provider
    /// function that interacts with your API to return a signed access token
    /// for your user.
    case custom(
        tokenProvider: ParraTokenProvider
    )

    /// Uses public API key authentication to authenticate with the Parra API.
    /// An API key ID is provided up front and a user provider function is used
    /// to allow the Parra SDK to request information about the current user
    /// when authentication is needed.
    case `public`(
        apiKeyId: String,
        userIdProvider: ParraUserIdProvider
    )

    case parraAuth(
        config: ParraAuthConfig = .default,
        content: ParraAuthContent = .default
    )

    // MARK: - Internal

    var supportsParraLoginScreen: Bool {
        switch self {
        case .parraAuth:
            return true
        default:
            return false
        }
    }
}
