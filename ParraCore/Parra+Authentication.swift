//
//  Parra+Authentication.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {
    @MainActor
    internal class func deinitialize() async {
        await shared.networkManager.updateAuthenticationProvider(nil)
        await ParraConfigState.shared.resetState()

        Parra.unregisterModule(module: shared)

        await ParraGlobalState.shared.deinitialize()
        await shared.sessionManager.endSession()
    }

    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProviderType) {
        Task { @MainActor in
            await initialize(config: config, authProvider: authProvider)
        }
    }
    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as
    /// early as possible inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's
    ///    access token. This function will be invoked automatically whenever the user's credential is missing or
    ///    expired and Parra needs to refresh the authentication state for your user.
    @MainActor
    class func initialize(config: ParraConfiguration = .default,
                          authProvider: ParraAuthenticationProviderType) async {
        if await ParraGlobalState.shared.isInitialized() {
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

        newConfig.setTenantId(tenantId)
        newConfig.setApplicationId(applicationId)
        
        await ParraConfigState.shared.updateState(newConfig)
        await shared.networkManager.updateAuthenticationProvider(authenticationProvider)
        await ParraGlobalState.shared.initialize()

        // Generally nothing that can generate events should happen before this call. Even logs
        await shared.sessionManager.createSessionIfNotExists()
        parraLogInfo("Parra SDK Initialized")

        do {
            let _ = try await shared.networkManager.refreshAuthentication()

            await performPostAuthRefreshActions()
        } catch let error {
            parraLogError("Authentication handler in call to Parra.initialize failed", error)
        }
    }

    private class func performPostAuthRefreshActions() async {
        parraLogDebug("Performing push authentication refresh actions.")

        await uploadCachedPushNotificationToken()
    }

    private class func uploadCachedPushNotificationToken() async {
        guard let token = await ParraGlobalState.shared.getCachedTemporaryPushToken() else {
            parraLogTrace("No push notification token is cached. Skipping upload.")
            return
        }

        parraLogTrace("Push notification token was cached. Attempting upload.")

        await uploadDevicePushToken(token)
    }

    @MainActor
    internal class func withAuthenticationMiddleware(
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
                        applicationId: applicationId,
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
