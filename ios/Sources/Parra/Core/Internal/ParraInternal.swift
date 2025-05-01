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
    // MARK: - Lifecycle

    init(
        appInfo: ParraAppInfo,
        requiresAuthRefresh: Bool = false
    ) {
        self.appInfo = appInfo
        self.requiresAuthRefresh = requiresAuthRefresh
    }

    // MARK: - Internal

    let appInfo: ParraAppInfo
    var requiresAuthRefresh: Bool
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
        sessionManager: SessionManager,
        api: API,
        notificationCenter: NotificationCenterType,
        feedback: ParraFeedback,
        releases: ParraReleases,
        appInfoManager: AppInfoManager,
        containerRenderer: ParraContainerRenderer,
        modalScreenManager: ModalScreenManager,
        authFlowManager: AuthenticationFlowManager,
        launchShortcutManager: LaunchShortcutManager
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
        self.modalScreenManager = modalScreenManager
        self.globalComponentFactory = ParraComponentFactory(
            attributes: configuration.globalComponentAttributes,
            theme: configuration.theme
        )
        self.authFlowManager = authFlowManager
        self.launchShortcutManager = launchShortcutManager
    }

    deinit {
        removeEventObservers()
    }

    // MARK: - Internal

    // MARK: - Statics

    /// Only change this if you change the module name in the Xcode project.
    static let moduleName = "Parra"
    static let errorDomain = "com.parra.error"

    static let libraryVersion = ParraPackageInfo.version

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

    @usableFromInline let sessionManager: SessionManager
    let api: API
    let notificationCenter: NotificationCenterType
    let appInfoManager: AppInfoManager
    let containerRenderer: ParraContainerRenderer
    let modalScreenManager: ModalScreenManager
    let authFlowManager: AuthenticationFlowManager
    let launchShortcutManager: LaunchShortcutManager

    var globalComponentFactory: ParraComponentFactory

    @MainActor
    func authStateDidChange(
        from oldAuthResult: ParraAuthState,
        to authResult: ParraAuthState
    ) async {
        if oldAuthResult == authResult {
            return
        }

        logger.debug("Auth state did change", [
            "from": oldAuthResult.description,
            "to": authResult.description
        ])

        switch (oldAuthResult, authResult) {
        case (_, .anonymous(let user)), (_, .authenticated(let user)):
            if !oldAuthResult.hasUser {
                // Changes from not logged in to logged in
                await handleLogin(for: user)
            }

        case (.anonymous(let user), _),
             (.authenticated(let user), _): // includes guest state
            // Changes from logged in to not logged in
            handleLogout(for: user)

        case (_, .undetermined):
            assertionFailure()

        // shouldn't ever change _to_ this.
        default:
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

    /// Must be completed before the splash screen is dismissed!
    /// Keep this as lean as possible!!!!
    /// Everything here should be expected to happen after receiving auth state.
    func performPostAuthLaunchActions(
        for user: ParraUser
    ) async throws {
        try await withThrowingDiscardingTaskGroup { taskGroup in
            taskGroup.addTask {
                logger.debug("Fetching user properties")

                do {
                    let userProperties = try await self.api.getUserProperties()

                    await ParraUserProperties.shared.forceSetStore(userProperties)
                } catch {
                    logger.error("Error fetching user properties", error)
                }
            }

            taskGroup.addTask {
                logger.debug("Fetching user entitlements")

                do {
                    let userEntitlements = try await self.api.getUserEntitlements()

                    await ParraUserEntitlements.shared.updateEntitlements(
                        userEntitlements
                    )
                } catch {
                    logger.error("Error fetching user entitlements", error)
                }
            }
        }
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
        logger.debug("Handle logout flow")

        ParraUserProperties.shared.reset()
        ParraUserSettings.shared.reset()
        ParraUserEntitlements.shared.reset()

        sessionManager.endSession()

        removeEventObservers()

        syncManager.stopSyncTimer()

        registerForPushNotifications()

        logger.info("User logged out", [
            "userId": user.info.id
        ])
    }

    @MainActor
    private func handleLogin(
        for user: ParraUser
    ) async {
        logger.debug("Handle login flow")

        await sessionManager.initializeSessions()

        Task {
            do {
                try await authService.refreshUserInfo()
            } catch {
                logger.error("Failed to refresh user info on app launch", error)
            }
        }

        addEventObservers()

        syncManager.startSyncTimer()

        registerForPushNotifications()
        registerShortcutItems()

        // Actions that should only happen once per app launch even if the user
        // logs in/out multiple times.
        if !hasPerformedSingleInitActions {
            hasPerformedSingleInitActions = true

            await performPostLoginSingleRunActions()
        }
    }

    private func performPostLoginSingleRunActions() async {
        let start = logger.debug("Performing post login actions")

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

        logger.measureTime(since: start, "Finished performing post login actions")
    }

    private func registerShortcutItems() {
        let options = configuration.launchShortcutOptions

        guard options.enabled else {
            logger.trace("Skipping shortcut registration. Not enabled.")

            return
        }

        let shortcutItems = options.shortcutItems

        guard !shortcutItems.isEmpty else {
            logger.trace(
                "Skipping shortcut registration. No shortcut items provided."
            )

            return
        }

        logger.debug("Registering \(shortcutItems.count) shortcut item(s).")

        Task { @MainActor in
            let app = UIApplication.shared
            let existingItems = app.shortcutItems ?? []

            let newShortcuts = shortcutItems.filter { !existingItems.contains($0) }

            app.shortcutItems = newShortcuts + existingItems
        }
    }

    private func registerForPushNotifications() {
        if configuration.pushNotificationOptions.enabled {
            logger.debug("Registering for remote notifications")

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()

                if configuration.pushNotificationOptions.promptTrigger == .automatic {
                    Parra.default.push.requestPushPermission()
                }
            }
        } else {
            logger.debug("Skipping remote notifications registration. Feature disabled.")
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

            appState.appInfo = appInfo

            return appInfo
        } catch {
            if let cachedAppInfo = await appInfoManager.cachedAppInfo() {
                logger.warn(
                    "Failed to fetch latest app info. Falling back on cache.",
                    error
                )

                return cachedAppInfo
            }

            logger.error(
                "Failed to fetch latest app info.",
                error
            )

            throw error
        }
    }
}
