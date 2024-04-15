//
//  ParraAuthenticationMethod.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraTokenProvider = () async throws -> String

public enum ParraAuthenticationMethod {
    /// The standard way of authenticating with Parra. You provide a provider
    /// function that interacts with your API to return a signed access token
    /// for your user.
    case custom(ParraTokenProvider)

    /// Uses public API key authentication to authenticate with the Parra API.
    /// A workspace ID and API key ID are both provided up front and a user
    /// provider function is used to allow the Parra SDK to request information
    /// about the current user when authentication is needed.
    case `public`(
        apiKeyId: String,
        userIdProvider: ParraTokenProvider
    )

    case parraAuth
}
