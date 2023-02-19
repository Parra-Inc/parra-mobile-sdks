//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    internal actor Initializer {
        internal static var isInitialized = false
    }

    /// Checks whether an authentication provider has already been set.
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as
    /// early as possible inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's
    ///    access token. This function will be invoked automatically whenever the user's credential is missing or
    ///    expired and Parra needs to refresh the authentication state for your user.
    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProviderType) {
        if Initializer.isInitialized {
            parraLogWarn("Parra.initialize called more than once. Subsequent calls are ignored")

            return
        }

        var newConfig = config

        let (tenantId, authenticationProvider) = withAuthenticationMiddleware(
            for: authProvider
        ) { [weak shared] success in
            guard let shared else {
                return
            }

            Task {
                if success {
                    shared.addEventObservers()
                    await shared.syncManager.startSyncTimer()
                } else {
                    await shared.dataManager.updateCredential(credential: nil)
                    await shared.syncManager.stopSyncTimer()
                }
            }
        }

        shared.networkManager.updateAuthenticationProvider(authenticationProvider)
        newConfig.setTenantId(tenantId)

        Parra.config = newConfig
        Parra.registerModule(module: shared)

        Initializer.isInitialized = true

        parraLogInfo("Parra SDK Initialized")

        Task {
            await shared.sessionManager.createSessionIfNotExists()

            do {
                let _ = try await shared.networkManager.refreshAuthentication()
            } catch let error {
                parraLogError("Authentication handler in call to Parra.initialize failed", error)
            }
        }
    }

    private class func withAuthenticationMiddleware(
        for authProvider: ParraAuthenticationProviderType,
        onAuthenticationRefresh: @escaping (_ success: Bool) -> Void
    ) -> (String, ParraAuthenticationProviderFunction) {
        

        switch authProvider {
        case .default(let tenantId, let authProvider):
            return (tenantId, { () async throws -> String in
                do {
                    let result = try await authProvider()

                    onAuthenticationRefresh(true)

                    return result
                } catch let error {
                    onAuthenticationRefresh(false)
                    throw error
                }
            })
            // () async throws -> String
        case .publicKey(let tenantId, let apiKeyId, let userIdProvider):
            return (tenantId, { [weak shared] () async throws -> String in
                do {
                    guard let networkManager = shared?.networkManager else {
                        throw ParraError.unknown
                    }

                    let userId = try await userIdProvider()

                    let result = try await networkManager.performPublicApiKeyAuthenticationRequest(
                        forTentant: tenantId,
                        apiKeyId: apiKeyId,
                        userId: userId
                    )

                    onAuthenticationRefresh(true)

                    return result
                } catch let error {
                    onAuthenticationRefresh(false)
                    throw error
                }
            })
        }
    }
}
