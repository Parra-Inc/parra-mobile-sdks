//
//  ParraInternal.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import os
import UIKit

struct LaunchActionsResult: Equatable {
    let appInfo: ParraAppInfo
}

private let logger = Logger(category: "Parra")

/// The internal Parra instance containing any top level references/functions
/// that need to be used from within the SDK. Nothing on this class should be
/// public.
@usableFromInline
class ParraInternal {
    // MARK: - Lifecycle

    init(
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        appState: ParraAppState,
        dataManager: DataManager,
        syncManager: ParraSyncManager,
        authService: AuthService,
        sessionManager: ParraSessionManager,
        api: API,
        notificationCenter: NotificationCenterType,
        feedback: ParraFeedback,
        releases: ParraReleases,
        appInfoManager: AppInfoManager,
        containerRenderer: ContainerRenderer,
        alertManager: AlertManager,
        modalScreenManager: ModalScreenManager
    ) {
        self.authenticationMethod = authenticationMethod
        self.configuration = configuration
        self.appState = appState
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.authService = authService
        self.sessionManager = sessionManager
        self.api = api
        self.notificationCenter = notificationCenter
        self.feedback = feedback
        self.releases = releases
        self.appInfoManager = appInfoManager
        self.containerRenderer = containerRenderer
        self.alertManager = alertManager
        self.modalScreenManager = modalScreenManager
        self.globalComponentFactory = ComponentFactory(
            attributes: configuration.globalComponentAttributes,
            theme: configuration.theme
        )
    }

    deinit {
        removeEventObservers()
    }

    // MARK: - Internal

    // MARK: - Statics

    /// Only change this if you change the module name in the Xcode project.
    static let moduleName = "Parra"
    static let errorDomain = "com.parra.error"

    // MARK: - Parra Modules

    let feedback: ParraFeedback
    let releases: ParraReleases

    var configuration: ParraConfiguration
    let authenticationMethod: ParraAuthType
    let appState: ParraAppState

    // MARK: - Managers

    let dataManager: DataManager
    let syncManager: ParraSyncManager
    let authService: AuthService

    @usableFromInline let sessionManager: ParraSessionManager
    let api: API
    let notificationCenter: NotificationCenterType
    let appInfoManager: AppInfoManager
    let containerRenderer: ContainerRenderer
    let alertManager: AlertManager
    let modalScreenManager: ModalScreenManager

    var globalComponentFactory: ComponentFactory

    static func libraryVersion() -> String {
        return Parra.appBundleVersionShort(
            bundle: .parraBundle
        ) ?? "unknown"
    }

    @MainActor
    func authStateDidChange(
        from oldAuthResult: ParraAuthResult,
        to authResult: ParraAuthResult
    ) async {
        switch (oldAuthResult, authResult) {
        case (_, .anonymous(let user)), (_, .authenticated(let user)):
            if !oldAuthResult.hasUser {
                // Changes from not logged in to logged in
                await handleLogin(for: user)
            }

        case (.anonymous(let user), _), (.authenticated(let user), _):
            // Changes from logged in to not logged in
            handleLogout(for: user)
        case (_, .undetermined):
            Parra.default.user.current = nil

            assertionFailure()
            
            // shouldn't ever change _to_ this.
        default:
            // TODO: Should there be a transition into guest mode?
            break
        }
    }

    /// Must be completed before the splash screen is dismissed!
    /// Keep this as lean as possible!!!!
    func performActionsRequiredForAppLaunch() async throws
        -> LaunchActionsResult
    {
        let start = Logger.info("Started launch screen actions")

        let appInfo = try await fetchLatestAppInfo()

        Logger.measureTime(since: start, "Launch screen actions completed")

        return LaunchActionsResult(
            appInfo: appInfo
        )
    }

    // MARK: - Private

    /// Not exactly the same as "is initialized." We need to handle the case
    /// where an authentication handler may fail. So actions that need to only
    /// be performed once, per invocation of auth handler refresh should take
    /// place when this is false.
    private var hasPerformedSingleInitActions = false

    @MainActor
    private func handleLogout(
        for user: ParraUser
    ) {
        sessionManager.endSession()

        Parra.default.user.current = nil

        removeEventObservers()

        syncManager.stopSyncTimer()

        logger.info("User logged out", [
            "userId": user.info.id
        ])
    }

    @MainActor
    private func handleLogin(
        for user: ParraUser
    ) async {
        // Set the user immediately so it can be used within services
        // invoked below.
        Parra.default.user.current = user

        var updatedUser = user

        await sessionManager.initializeSessions()

        do {
            logger.debug("Refreshing user info")

            // If refresh was successful, we need to make sure this is the
            // user that becomes immediately accessible outside the SDK.
            if let next = try await authService.refreshUserInfo() {
                updatedUser = next
            }
        } catch {
            logger.error("Failed to refresh user info on app launch", error)
        }

        // Update the user again after refreshing over the network.
        Parra.default.user.current = updatedUser

        addEventObservers()

        syncManager.startSyncTimer()

        // Actions that should only happen once per app launch even if the user
        // logs in/out multiple times.
        if !hasPerformedSingleInitActions {
            hasPerformedSingleInitActions = true

            await performPostLoginSingleRunActions()
        }
    }

    private func performPostLoginSingleRunActions() async {
        logger.debug("Performing post login actions")

        if configuration.pushNotificationOptions.enabled {
            logger.debug("Registering for remote notifications")

            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        let whatsNewOptions = configuration.whatsNewOptions

        // only runs once if authenticated. It's fine if this doesn't run
        // in the event there was a timeout fetching app info during the
        // splash screen

        if let appInfo = appState.appInfo {
            switch whatsNewOptions.presentationMode {
            case .automatic, .delayed:
                Task {
                    await appInfoManager.checkAndPresentWhatsNew(
                        against: appInfo,
                        with: whatsNewOptions,
                        using: modalScreenManager
                    )
                }
            case .manual:
                break
            }
        }
    }

    private func fetchLatestAppInfo() async throws -> ParraAppInfo {
        do {
            let appInfo = try await appInfoManager.fetchLatestAppInfo(
                force: true,
                timeout: 5.0
            )

            logger.debug("Fetched latest app info", [
                "versionToken": String(describing: appInfo.versionToken)
            ])

            // Do NOT await this. We don't want to block the splash screen.
            Task { @MainActor in
                appState.appInfo = appInfo
            }

            return appInfo
        } catch {
            logger.error("Failed to fetch latest app info", error)

            throw error
        }
    }
}
