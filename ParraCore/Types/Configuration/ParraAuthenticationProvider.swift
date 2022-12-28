//
//  ParraAuthenticationProvider.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraAuthenticationProviderFunction = () async throws -> String

public enum ParraAuthenticationProviderType {
    /// The standard way of authenticating with Parra. You provide a provider function that interacts with your API to return
    /// a signed access token for your user.
    case `default`(provider: ParraAuthenticationProviderFunction)

    /// Uses public API key authentication to authenticate with the Parra API. A tenant ID and API key ID are both provided up front
    /// and a user provider function is used to allow the Parra SDK to request information about the current user when authentication is needed.
    case publicKey(tenantId: String, apiKeyId: String, userIdProvider: ParraAuthenticationProviderFunction)
}
