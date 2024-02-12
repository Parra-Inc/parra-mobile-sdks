//
//  ParraAuthenticationProviderType.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public typealias ParraAuthenticationProviderFunction = () async throws -> String

@MainActor
public enum ParraAuthenticationProviderType {
    /// The standard way of authenticating with Parra. You provide a provider
    /// function that interacts with your API to return a signed access token
    /// for your user.
    case `default`(
        tenantId: String,
        applicationId: String,
        authProvider: ParraAuthenticationProviderFunction
    )

    /// Uses public API key authentication to authenticate with the Parra API.
    /// A tenant ID and API key ID are both provided up front and a user
    /// provider function is used to allow the Parra SDK to request information
    /// about the current user when authentication is needed.
    case publicKey(
        tenantId: String,
        applicationId: String,
        apiKeyId: String,
        userIdProvider: ParraAuthenticationProviderFunction
    )

    // MARK: - Internal

    var initialAppState: ParraAppState {
        switch self {
        case .default(let tenantId, let applicationId, _):
            return ParraAppState(
                tenantId: tenantId,
                applicationId: applicationId
            )
        case .publicKey(let tenantId, let applicationId, _, _):
            return ParraAppState(
                tenantId: tenantId,
                applicationId: applicationId
            )
        }
    }

    func getProviderFunction(
        using networkManager: ParraNetworkManager,
        onAuthenticationRefresh: @escaping (_ success: Bool) async -> Void
    ) -> ParraAuthenticationProviderFunction {
        switch self {
        case .default(let tenantId, let applicationId, let authProvider):
            return { () async throws -> String in
                do {
                    let result = try await authProvider()

                    await onAuthenticationRefresh(true)

                    return result
                } catch {
                    await onAuthenticationRefresh(false)

                    throw error
                }
            }
        case .publicKey(
            let tenantId,
            let applicationId,
            let apiKeyId,
            let userIdProvider
        ):
            return { () async throws -> String in
                do {
                    let userId = try await userIdProvider()

                    let result = try await networkManager
                        .performPublicApiKeyAuthenticationRequest(
                            forTentant: tenantId,
                            applicationId: applicationId,
                            apiKeyId: apiKeyId,
                            userId: userId
                        )

                    await onAuthenticationRefresh(true)

                    return result
                } catch {
                    await onAuthenticationRefresh(false)

                    throw error
                }
            }
        }
    }
}
