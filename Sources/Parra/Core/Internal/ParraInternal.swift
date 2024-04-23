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
        authState: ParraAuthState,
        dataManager: DataManager,
        syncManager: ParraSyncManager,
        authService: AuthService,
        sessionManager: ParraSessionManager,
        api: API,
        notificationCenter: NotificationCenterType,
        feedback: ParraFeedback,
        latestVersionManager: LatestVersionManager,
        containerRenderer: ContainerRenderer,
        alertManager: AlertManager,
        modalScreenManager: ModalScreenManager
    ) {
        self.authenticationMethod = authenticationMethod
        self.configuration = configuration
        self.appState = appState
        self.authState = authState
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.authService = authService
        self.sessionManager = sessionManager
        self.api = api
        self.notificationCenter = notificationCenter
        self.feedback = feedback
        self.latestVersionManager = latestVersionManager
        self.containerRenderer = containerRenderer
        self.alertManager = alertManager
        self.modalScreenManager = modalScreenManager
        self.globalComponentFactory = ComponentFactory(
            global: configuration.globalComponentAttributes,
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

    var currentUser: ParraUser?

    // MARK: - Parra Modules

    let feedback: ParraFeedback

    var configuration: ParraConfiguration
    let authenticationMethod: ParraAuthType
    let appState: ParraAppState
    let authState: ParraAuthState

    // MARK: - Managers

    let dataManager: DataManager
    let syncManager: ParraSyncManager
    let authService: AuthService

    @usableFromInline let sessionManager: ParraSessionManager
    let api: API
    let notificationCenter: NotificationCenterType
    let latestVersionManager: LatestVersionManager
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

            await performPostInitialAuthActions()
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

    // MARK: - Private

    /// Not exactly the same as "is initialized." We need to handle the case
    /// where an authentication handler may fail. So actions that need to only
    /// be performed once, per invocation of auth handler refresh should take
    /// place when this is false.
    private var hasPerformedSingleInitActions = false

    @MainActor
    private func performPostInitialAuthActions() async {
        logger.debug("Performing push authentication refresh actions.")

        await sessionManager.initializeSessions()

        if configuration.pushNotificationOptions.enabled {
            UIApplication.shared.registerForRemoteNotifications()
        }

        let whatsNewOptions = configuration.whatsNewOptions

        switch whatsNewOptions.presentationMode {
        case .automatic, .delayed:

            Task {
                await latestVersionManager.fetchAndPresentWhatsNew(
                    with: whatsNewOptions,
                    using: modalScreenManager
                )
            }
        case .manual:
            break
        }
    }
}
