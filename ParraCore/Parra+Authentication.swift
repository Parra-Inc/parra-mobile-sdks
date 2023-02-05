//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    actor Initializer {
        static var isInitialized = false
    }

    /// Checks whether an authentication provider has already been set.
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as early as possible
    /// inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's access token.
    ///   This function will be invoked automatically whenever the user's credential is missing or expired and Parra needs to refresh
    ///   the authentication state for your user.
    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProviderType) {
        Task {
            if Initializer.isInitialized {
                parraLogW("Parra.initialize called more than once. Subsequent calls are ignored")
                return
            }

            await shared.sessionManager.createSessionIfNotExists()

            var newConfig = config

            switch authProvider {
            case .default(let tenantId, let provider):
                shared.networkManager.updateAuthenticationProvider(provider)

                newConfig.setTenantId(tenantId)
            case .publicKey(let tenantId, let apiKeyId, let userIdProvider):
                shared.networkManager.updateAuthenticationProvider { [weak shared] in
                    guard let networkManager = shared?.networkManager else {
                        throw ParraError.unknown
                    }

                    let userId = try await userIdProvider()

                    return try await networkManager.performPublicApiKeyAuthenticationRequest(
                        forTentant: tenantId,
                        apiKeyId: apiKeyId,
                        userId: userId
                    )
                }

                newConfig.setTenantId(tenantId)
            }

            Parra.config = newConfig
            Initializer.isInitialized = true

            Task {
                do {
                    let _ = try await shared.networkManager.refreshAuthentication()
                } catch let error {
                    parraLogE("Refresh authentication on user change: \(error)")
                }
            }

            parraLogI("Parra SDK Initialized")
        }
    }
}
