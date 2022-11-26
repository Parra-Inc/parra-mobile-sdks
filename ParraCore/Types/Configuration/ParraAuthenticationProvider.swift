//
//  ParraAuthenticationProvider.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraAuthenticationProviderFunction = () async throws -> String

public protocol ParraAuthenticationProvider {
    func retreiveCredential() async throws -> String
}

public struct ParraDefaultAuthenticationProvider: ParraAuthenticationProvider {
    public let userProvider: ParraAuthenticationProviderFunction

    public init(userProvider: @escaping ParraAuthenticationProviderFunction) {
        self.userProvider = userProvider
    }

    public func retreiveCredential() async throws -> String {
        return try await userProvider()
    }
}

/// Uses public API key authentication to authenticate with the Parra API. A tenant ID and API key ID are both provided up front
/// and a user provider function is used to allow the Parra SDK to request information about the current user when authentication is needed.
public struct ParraPublicKeyAuthenticationProvider: ParraAuthenticationProvider {
    public let tenantId: String
    public let apiKeyId: String
    public let userProvider: ParraAuthenticationProviderFunction

    public init(tenantId: String,
                apiKeyId: String,
                userProvider: @escaping ParraAuthenticationProviderFunction) {

        self.tenantId = tenantId
        self.apiKeyId = apiKeyId
        self.userProvider = userProvider
    }

    public func retreiveCredential() async throws -> String {
        let userId = try await userProvider()

        return try await Parra.shared.networkManager.performPublicApiKeyAuthenticationRequest(
            forTentant: tenantId,
            apiKeyId: apiKeyId,
            userId: userId
        )
    }
}
