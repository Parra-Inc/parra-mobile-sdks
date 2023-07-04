//
//  Parra+Authentication.swift
//  Parra
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

public extension Parra {

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as
    /// early as possible inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's
    ///    access token. This function will be invoked automatically whenever the user's credential is missing or
    ///    expired and Parra needs to refresh the authentication state for your user.
    static func initialize(
        options: [ParraConfigurationOption] = [],
        authProvider: ParraAuthenticationProviderType
    ) {
        shared.initialize(
            options: options,
            authProvider: authProvider
        )
    }

    internal func initialize(
        options: [ParraConfigurationOption] = [],
        authProvider: ParraAuthenticationProviderType
    ) {
        Task { @MainActor in
            await initialize(options: options, authProvider: authProvider)
        }
    }

    /// Initializes the Parra SDK using the provided configuration and auth provider. This method should be invoked as
    /// early as possible inside of applicationDidFinishLaunchingWithOptions.
    /// - Parameters:
    ///   - authProvider: An async function that is expected to return a ParraCredential object containing a user's
    ///    access token. This function will be invoked automatically whenever the user's credential is missing or
    ///    expired and Parra needs to refresh the authentication state for your user.

    @MainActor
    static func initialize(
        options: [ParraConfigurationOption] = [],
        authProvider: ParraAuthenticationProviderType
    ) async {
        await shared.initialize(
            options: options,
            authProvider: authProvider
        )
    }

    @MainActor
    internal func initialize(
        options: [ParraConfigurationOption] = [],
        authProvider: ParraAuthenticationProviderType
    ) async {
        if await state.isInitialized() {
            parraLogWarn("Parra.initialize called more than once. Subsequent calls are ignored")

            return
        }

        var newConfig = ParraConfiguration(options: options)

        let (tenantId, applicationId, authenticationProvider) = withAuthenticationMiddleware(
            for: authProvider
        ) { [weak self] success in
            guard let self else {
                return
            }

            Task {
                if success {
                    self.addEventObservers()
                    self.syncManager.startSyncTimer()
                } else {
                    await self.dataManager.updateCredential(credential: nil)
                    self.syncManager.stopSyncTimer()
                }
            }
        }

        newConfig.setTenantId(tenantId)
        newConfig.setApplicationId(applicationId)

        let modules: [ParraModule] = [Parra.shared, ParraFeedback.shared]
        for module in modules {
            await state.registerModule(module: module)
        }

        await configState.updateState(newConfig)
        await networkManager.updateAuthenticationProvider(authenticationProvider)
        await state.initialize()

        // Generally nothing that can generate events should happen before this call. Even logs
        await sessionManager.createSessionIfNotExists()
        parraLogInfo("Parra SDK Initialized")

        do {
            let _ = try await networkManager.refreshAuthentication()

            await performPostAuthRefreshActions()
        } catch let error {
            parraLogError("Authentication handler in call to Parra.initialize failed", error)
        }
    }

    private func performPostAuthRefreshActions() async {
        parraLogDebug("Performing push authentication refresh actions.")

        await uploadCachedPushNotificationToken()
    }

    private func uploadCachedPushNotificationToken() async {
        guard let token = await state.getCachedTemporaryPushToken() else {
            parraLogTrace("No push notification token is cached. Skipping upload.")
            return
        }

        parraLogTrace("Push notification token was cached. Attempting upload.")

        await uploadDevicePushToken(token)
    }

    @MainActor
    internal func withAuthenticationMiddleware(
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
            return (tenantId, applicationId, { [weak self] () async throws -> String in
                do {
                    guard let networkManager = self?.networkManager else {
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
