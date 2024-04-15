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
        authenticationMethod: ParraAuthenticationMethod,
        configuration: ParraConfiguration,
        appState: ParraAppState,
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

    // MARK: - Public

    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public func logout() async {
        await syncManager.enqueueSync(with: .immediate)
        await dataManager.updateCredential(credential: nil)
        await syncManager.stopSyncTimer()
        await authService.logout()
    }

    // MARK: - Synchronization

    /// Parra data is syncrhonized automatically. Use this method if you wish to
    /// trigger a synchronization event manually. This may be something you want
    /// to do in response to a significant event in your app, or in response to
    /// a low memory warning, for example. Note that in order to prevent
    /// excessive network activity it may take up to 30 seconds for the sync to
    /// complete after being initiated.
    public func triggerSync() async {
        // Uploads any cached Parra data. This includes data like answers to
        // questions. Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }

    // MARK: - Theme

    public func updateTheme(to newTheme: ParraTheme) {
        let oldTheme = configuration.theme
        configuration.theme = newTheme

        globalComponentFactory = ComponentFactory(
            global: configuration.globalComponentAttributes,
            theme: newTheme
        )

        notificationCenter.post(
            name: Parra.themeWillChangeNotification,
            object: nil,
            userInfo: [
                "oldTheme": oldTheme,
                "newTheme": newTheme
            ]
        )
    }

    // MARK: - Internal

    // MARK: - Statics

    /// Only change this if you change the module name in the Xcode project.
    static let moduleName = "Parra"
    static let errorDomain = "com.parra.error"

    var currentUser: ParraUser?

    // MARK: - Parra Modules

    let feedback: ParraFeedback

    private(set) var configuration: ParraConfiguration
    let authenticationMethod: ParraAuthenticationMethod
    let appState: ParraAppState

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

    private(set) var globalComponentFactory: ComponentFactory

    static func libraryVersion() -> String {
        return ParraInternal.appBundleVersionShort(
            bundle: .parraBundle
        ) ?? "unknown"
    }

    @MainActor
    func currentUserDidChange(
        to user: ParraUser?
    ) async {
        // These actions should be completed before the success conditional ones
        if !hasPerformedSingleInitActions {
            hasPerformedSingleInitActions = true

            await performPostInitialAuthActions()
        }

        if user != nil {
            addEventObservers()

            syncManager.startSyncTimer()
        } else {
            removeEventObservers()

            await dataManager.updateCredential(credential: nil)
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
