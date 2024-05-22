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

struct LaunchActionsResult {
    let authInfo: ParraAppAuthInfo
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
        return ParraInternal.appBundleVersionShort(
            bundle: .parraBundle
        ) ?? "unknown"
    }

    @MainActor
    func authStateDidChange(
        to result: ParraAuthResult
    ) async {
        // These actions should be completed before the success conditional ones
        if !hasPerformedSingleInitActions {
            hasPerformedSingleInitActions = true

            await performPostLaunchAuthOptionalActions()

            if case .authenticated = result {
                await performPostLaunchAuthRequiredActions()
            }
        }

        switch result {
        case .authenticated:
            addEventObservers()

            syncManager.startSyncTimer()
        case .unauthenticated:
            removeEventObservers()

            syncManager.stopSyncTimer()
        }
    }

    // 1. Post app launch, before splash dismisses
    // 2. Post auth refresh
    //    a. authenticated
    //    b. unauthenticated

    /// Must be completed before the splash screen is dismissed!
    /// Keep this as lean as possible!!!!
    func performActionsRequiredForAppLaunch() async throws
        -> LaunchActionsResult
    {
        let authInfo = try await fetchLatestAppInfo()

        return LaunchActionsResult(
            authInfo: authInfo
        )
    }

    // MARK: - Private

    /// Not exactly the same as "is initialized." We need to handle the case
    /// where an authentication handler may fail. So actions that need to only
    /// be performed once, per invocation of auth handler refresh should take
    /// place when this is false.
    private var hasPerformedSingleInitActions = false

    private func performPostLaunchAuthOptionalActions() async {
        logger.debug("Performing first launch auth optional actions.")
    }

    private func performPostLaunchAuthRequiredActions() async {
        logger.debug("Performing first launch auth required actions.")

        await sessionManager.initializeSessions()

        if configuration.pushNotificationOptions.enabled {
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

    private func fetchLatestAppInfo() async throws -> ParraAppAuthInfo {
        do {
            let appInfo = try await appInfoManager.fetchLatestAppInfo(
                force: true,
                timeout: 5.0
            )

            logger.debug("Fetched latest app info", [
                "versionToken": appInfo.versionToken
            ])

            appState.appInfo = appInfo

            return appInfo.auth
        } catch {
            logger.error("Failed to fetch latest app info", error)

            throw error
        }
    }
}
