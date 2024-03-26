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

        let networkManager = ParraNetworkManager(
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager,
            configuration: instanceConfiguration.networkConfiguration
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            networkManager: networkManager,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            syncState: syncState,
            networkManager: networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let latestVersionManager = LatestVersionManager(
            networkManager: networkManager
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
            networkManager: networkManager
        )

        Logger.loggerBackend = sessionManager

        let parra = ParraInternal(
            configuration: configuration,
            appState: appState,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager
        )

        networkManager.delegate = parra
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

        let networkManager = ParraNetworkManager(
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager,
            configuration: instanceConfiguration.networkConfiguration
        )

        let sessionManager = ParraSessionManager(
            forceDisabled: true,
            dataManager: dataManager,
            networkManager: networkManager,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            forceDisabled: true,
            syncState: syncState,
            networkManager: networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let latestVersionManager = LatestVersionManager(
            networkManager: networkManager
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
            networkManager: networkManager
        )

        Logger.loggerBackend = sessionManager

        let parra = ParraInternal(
            configuration: configuration,
            appState: appState,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager
        )

        networkManager.delegate = parra
        syncManager.delegate = parra

        return (parra, appState)
    }
}
