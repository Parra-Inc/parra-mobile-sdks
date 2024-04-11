//
//  ParraInternal+Factory.swift
//  Parra
//
//  Created by Mick MacCallum on 2/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Majorly needs deduplicated

extension ParraInternal {
    @MainActor
    static func createParraInstance(
        authProvider: ParraAuthenticationProviderType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> (ParraInternal, ParraAppState) {
        let appState = authProvider.initialAppState
        let syncState = ParraSyncState()
        let fileManager = FileManager.default

        // Common

        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                baseUrl: instanceConfiguration.storageConfiguration
                    .baseDirectory,
                folder: instanceConfiguration.storageConfiguration
                    .storageDirectoryName,
                fileName: ParraDataManager.Key.userCredentialsKey,
                storeItemsSeparately: false,
                fileManager: fileManager
            ),
            jsonEncoder: instanceConfiguration.storageConfiguration
                .sessionJsonEncoder,
            jsonDecoder: instanceConfiguration.storageConfiguration
                .sessionJsonDecoder
        )

        let sessionStorageUrl = instanceConfiguration.storageConfiguration
            .baseDirectory
            .appendDirectory(
                instanceConfiguration.storageConfiguration
                    .storageDirectoryName
            )
            .appendDirectory("sessions")

        let notificationCenter = ParraNotificationCenter()

        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let sessionStorage = SessionStorage(
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: fileManager
            ),
            sessionJsonEncoder: .parraEncoder,
            eventJsonEncoder: .spaceOptimizedEncoder
        )

        let dataManager = ParraDataManager(
            baseDirectory: instanceConfiguration.storageConfiguration
                .baseDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )

        let apiResourceServer = ApiResourceServer(
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager,
            configuration: instanceConfiguration.networkConfiguration
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            apiResourceServer: apiResourceServer,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            syncState: syncState,
            apiResourceServer: apiResourceServer,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            apiResourceServer: apiResourceServer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let alertManager = AlertManager()

        let latestVersionManager = LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            apiResourceServer: apiResourceServer
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
            apiResourceServer: apiResourceServer
        )

        Logger.loggerBackend = sessionManager

        let parra = ParraInternal(
            configuration: configuration,
            appState: appState,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            apiResourceServer: apiResourceServer,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager,
            containerRenderer: containerRenderer,
            alertManager: alertManager,
            modalScreenManager: modalScreenManager
        )

        apiResourceServer.delegate = parra
        syncManager.delegate = parra

        return (parra, appState)
    }

    // Largely the same but disables sessions/sync/etc to prevent sending this
    // often mocked data to our servers.
    @MainActor
    static func createParraSwiftUIPreviewsInstance(
        authProvider: ParraAuthenticationProviderType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> (ParraInternal, ParraAppState) {
        let appState = authProvider.initialAppState
        let syncState = ParraSyncState()
        let fileManager = FileManager.default

        // Common

        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                baseUrl: instanceConfiguration.storageConfiguration
                    .baseDirectory,
                folder: instanceConfiguration.storageConfiguration
                    .storageDirectoryName,
                fileName: ParraDataManager.Key.userCredentialsKey,
                storeItemsSeparately: false,
                fileManager: fileManager
            ),
            jsonEncoder: instanceConfiguration.storageConfiguration
                .sessionJsonEncoder,
            jsonDecoder: instanceConfiguration.storageConfiguration
                .sessionJsonDecoder
        )

        let sessionStorageUrl = instanceConfiguration.storageConfiguration
            .baseDirectory
            .appendDirectory(
                instanceConfiguration.storageConfiguration
                    .storageDirectoryName
            )
            .appendDirectory("sessions")

        let notificationCenter = ParraNotificationCenter()

        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let sessionStorage = SessionStorage(
            forceDisabled: true,
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: fileManager
            ),
            sessionJsonEncoder: .parraEncoder,
            eventJsonEncoder: .spaceOptimizedEncoder
        )

        let dataManager = ParraDataManager(
            baseDirectory: instanceConfiguration.storageConfiguration
                .baseDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )

        let apiResourceServer = ApiResourceServer(
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager,
            configuration: instanceConfiguration.networkConfiguration
        )

        let sessionManager = ParraSessionManager(
            forceDisabled: true,
            dataManager: dataManager,
            apiResourceServer: apiResourceServer,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            forceDisabled: true,
            syncState: syncState,
            apiResourceServer: apiResourceServer,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            apiResourceServer: apiResourceServer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let alertManager = AlertManager()

        let latestVersionManager = LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            apiResourceServer: apiResourceServer
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
            apiResourceServer: apiResourceServer
        )

        Logger.loggerBackend = sessionManager

        let parra = ParraInternal(
            configuration: configuration,
            appState: appState,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            apiResourceServer: apiResourceServer,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager,
            containerRenderer: containerRenderer,
            alertManager: alertManager,
            modalScreenManager: modalScreenManager
        )

        apiResourceServer.delegate = parra
        syncManager.delegate = parra

        return (parra, appState)
    }
}
