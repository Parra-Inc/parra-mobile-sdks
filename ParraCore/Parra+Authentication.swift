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
    @MainActor
    class func hasAuthenticationProvider() -> Bool {
        return shared.networkManager.authenticationProvider != nil
    }

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as
    /// early as possible inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's
    ///    access token. This function will be invoked automatically whenever the user's credential is missing or
    ///    expired and Parra needs to refresh the authentication state for your user.
    @MainActor
    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProviderType) {
        if Initializer.isInitialized {
            parraLogWarn("Parra.initialize called more than once. Subsequent calls are ignored")

            return
        }

        var newConfig = config

        let (tenantId, applicationId, authenticationProvider) = withAuthenticationMiddleware(
            for: authProvider
        ) { [weak shared] success in
            guard let shared else {
                return
            }

            Task {
                if success {
                    shared.addEventObservers()
                    shared.syncManager.startSyncTimer()
                } else {
                    await shared.dataManager.updateCredential(credential: nil)
                    shared.syncManager.stopSyncTimer()
                }
            }
        }

        shared.networkManager.updateAuthenticationProvider(authenticationProvider)
        newConfig.setTenantId(tenantId)
        newConfig.setApplicationId(applicationId)

        Parra.config = newConfig
        Parra.registerModule(module: shared)

        Initializer.isInitialized = true

        Task {
            // Generally nothing that can generate events should happen before this call. Even logs
            await shared.sessionManager.createSessionIfNotExists()
            parraLogInfo("Parra SDK Initialized")

            do {
                let _ = try await shared.networkManager.refreshAuthentication()

                await performPoshAuthRefreshActions()
            } catch let error {
                parraLogError("Authentication handler in call to Parra.initialize failed", error)
            }
        }
    }

    private class func performPoshAuthRefreshActions() async {
        parraLogDebug("Performing push authentication refresh actions.")

        await uploadCachedPushNotificationToken()
    }

    private class func uploadCachedPushNotificationToken() async {
        guard let token = await PushTokenState.shared.getCachedTemporaryPushToken() else {
            parraLogTrace("No push notification token is cached. Skipping upload.")
            return
        }

        parraLogTrace("Push notification token was cached. Attempting upload.")

        await uploadDevicePushToken(token)
    }

    @MainActor
    private class func withAuthenticationMiddleware(
        for authProvider: ParraAuthenticationProviderType,
        onAuthenticationRefresh: @escaping (_ success: Bool) -> Void
    ) -> (String, String, ParraAuthenticationProviderFunction) {
        

        switch authProvider {
        case .default(let tenantId, let applicationId, let authProvider):
            return (tenantId, applicationId, { () async throws -> String in
                do {
                    let result = try await authProvider()

                    onAuthenticationRefresh(true)

                    return result
                } catch let error {
                    onAuthenticationRefresh(false)
                    throw error
                }
            })
        case .publicKey(let tenantId, let applicationId, let apiKeyId, let userIdProvider):
            return (tenantId, applicationId, { [weak shared] () async throws -> String in
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
