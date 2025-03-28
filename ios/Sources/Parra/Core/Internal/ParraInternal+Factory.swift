//
//  ParraInternal+Factory.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    @MainActor
    static func createParraInstance(
        appState: ParraAppState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        let disableSessions = configuration.loggerOptions.environment.hasConsoleBehavior
            && !ParraLoggerEnvironment.eventDebugLoggingOverrideEnabled

        if disableSessions {
            ParraLogger.debug("Disabling sessions/sync/etc.")
        }

        return _createParraInstance(
            forceDisabled: disableSessions,
            appState: appState,
            authenticationMethod: authenticationMethod,
            configuration: configuration,
            instanceConfiguration: instanceConfiguration
        )
    }

    // Largely the same but disables sessions/sync/etc to prevent sending this
    // often mocked data to our servers.
    @MainActor
    static func createParraSwiftUIPreviewsInstance(
        appState: ParraAppState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        return _createParraInstance(
            forceDisabled: true,
            appState: appState,
            authenticationMethod: authenticationMethod,
            configuration: configuration,
            instanceConfiguration: instanceConfiguration
        )
    }

    @MainActor
    /// Creates a Parra instance with the given configuration.
    /// - Parameters:
    ///   - forceDisabled: Whether functions that we won't want to run in
    ///   SwiftUI previews should be disabled.
    private static func _createParraInstance(
        forceDisabled: Bool,
        appState: ParraAppState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        let syncState = ParraSyncState()
        let fileManager = FileManager.default

        // Common

        let storageConfig = instanceConfiguration.storageConfiguration

        let sessionStorageUrl = storageConfig
            .baseDirectory
            .appendDirectory(
                storageConfig.storageDirectoryName
            )
            .appendDirectory("sessions")

        let credentialStorageModule = ParraStorageModule<ParraUser>(
            dataStorageMedium: .fileSystemEncrypted(
                baseUrl: storageConfig.baseDirectory,
                folder: "credentials",
                fileName: DataManager.Key.userCredentialsKey,
                fileManager: fileManager
            ),
            jsonEncoder: storageConfig.sessionJsonEncoder,
            jsonDecoder: storageConfig.sessionJsonDecoder,
            deleteFilesOnReadError: true
        )

        let notificationCenter = ParraNotificationCenter.default
        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let containerRenderer = ParraContainerRenderer(
            configuration: configuration
        )

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let sessionJsonEncoder = JSONEncoder.parraEncoder
        let sessionStorage = SessionStorage(
            forceDisabled: forceDisabled,
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                sessionJsonEncoder: sessionJsonEncoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: fileManager
            ),
            sessionJsonEncoder: sessionJsonEncoder,
            eventJsonEncoder: .spaceOptimizedEncoder
        )

        let dataManager = DataManager(
            baseDirectory: instanceConfiguration.storageConfiguration
                .baseDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )

        let authServer = AuthServer(
            appState: appState,
            appConfig: configuration,
            configuration: instanceConfiguration.authServerConfiguration,
            dataManager: dataManager
        )

        let externalResourceServer = ExternalResourceServer(
            configuration: instanceConfiguration.externalServerConfiguration,
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager
        )

        let oauth2Service = OAuth2Service(
            clientId: appState.applicationId,
            tenantId: appState.tenantId,
            authServer: authServer
        )

        let authService = AuthService(
            oauth2Service: oauth2Service,
            dataManager: dataManager,
            authServer: authServer,
            authenticationMethod: authenticationMethod,
            modalScreenManager: modalScreenManager
        )

        let apiResourceServer = ApiResourceServer(
            authService: authService,
            dataManager: dataManager,
            appState: appState,
            appConfig: configuration,
            configuration: instanceConfiguration.apiServerConfiguration
        )

        let api = API(
            appState: appState,
            apiResourceServer: apiResourceServer,
            dataManager: dataManager
        )

        let metricManager = MetricManager()

        let sessionManager = SessionManager(
            api: api,
            dataManager: dataManager,
            loggerOptions: configuration.loggerOptions,
            metricManager: metricManager,
            forceDisabled: forceDisabled
        )

        let syncManager = ParraSyncManager(
            forceDisabled: forceDisabled,
            syncState: syncState,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let appInfoManager = AppInfoManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            api: api,
            authServer: authServer,
            externalResourceServer: externalResourceServer,
            dataManager: dataManager,
            fileManager: fileManager
        )

        // Parra Modules

        let feedback = ParraFeedback(
            dataManager: ParraFeedbackDataManager(
                dataManager: dataManager,
                syncManager: syncManager,
                jsonEncoder: JSONEncoder.parraEncoder,
                jsonDecoder: JSONDecoder.parraDecoder,
                fileManager: fileManager,
                notificationCenter: notificationCenter
            ),
            api: api,
            apiResourceServer: apiResourceServer
        )

        let releases = ParraReleases(
            api: api,
            apiResourceServer: apiResourceServer,
            appInfoManager: appInfoManager
        )

        let launchShortcutManager = LaunchShortcutManager(
            options: configuration.launchShortcutOptions,
            modalScreenManager: modalScreenManager,
            api: api,
            feedback: feedback
        )

        let authFlowManager = AuthenticationFlowManager(
            authService: authService,
            modalScreenManager: modalScreenManager
        )

        do {
            try Logger.addLoggerBackend(sessionManager)
        } catch {
            Logger.fatal("Failed to attach logger backend", error)
        }

        let parra = ParraInternal(
            authenticationMethod: authenticationMethod,
            configuration: configuration,
            appState: appState,
            dataManager: dataManager,
            syncManager: syncManager,
            authService: authService,
            sessionManager: sessionManager,
            api: api,
            notificationCenter: notificationCenter,
            feedback: feedback,
            releases: releases,
            appInfoManager: appInfoManager,
            containerRenderer: containerRenderer,
            modalScreenManager: modalScreenManager,
            authFlowManager: authFlowManager,
            launchShortcutManager: launchShortcutManager
        )

        apiResourceServer.delegate = parra
        syncManager.delegate = parra

        return parra
    }
}
