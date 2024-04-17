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
        authState: ParraAuthState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        return _createParraInstance(
            forceDisabled: false,
            appState: appState,
            authState: authState,
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
        authState: ParraAuthState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        return _createParraInstance(
            forceDisabled: true,
            appState: appState,
            authState: authState,
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
        authState: ParraAuthState,
        authenticationMethod: ParraAuthType,
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration = .default
    ) -> ParraInternal {
        let syncState = ParraSyncState()
        let fileManager = FileManager.default

        // Common

        let credentialStorageModule = ParraStorageModule<ParraUser>(
            dataStorageMedium: .fileSystem(
                baseUrl: instanceConfiguration.storageConfiguration
                    .baseDirectory,
                folder: instanceConfiguration.storageConfiguration
                    .storageDirectoryName,
                fileName: DataManager.Key.userCredentialsKey,
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

        let notificationCenter = ParraNotificationCenter.default

        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let sessionStorage = SessionStorage(
            forceDisabled: forceDisabled,
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: fileManager
            ),
            sessionJsonEncoder: .parraEncoder,
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
            configuration: instanceConfiguration.serverConfiguration
        )

        let externalResourceServer = ExternalResourceServer(
            configuration: instanceConfiguration.serverConfiguration
        )

        let oauth2Service = OAuth2Service(
            clientId: appState.applicationId,
            tenantId: appState.tenantId,
            authServer: authServer
        )

        let authService = AuthService(
            appState: appState,
            oauth2Service: oauth2Service,
            dataManager: dataManager,
            authServer: authServer,
            authenticationMethod: authenticationMethod
        )

        let apiResourceServer = ApiResourceServer(
            authService: authService,
            appState: appState,
            appConfig: configuration,
            dataManager: dataManager,
            configuration: instanceConfiguration.serverConfiguration
        )

        let api = API(
            appState: appState, apiResourceServer: apiResourceServer
        )

        let sessionManager = ParraSessionManager(
            forceDisabled: forceDisabled,
            dataManager: dataManager,
            api: api,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            forceDisabled: forceDisabled,
            syncState: syncState,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let alertManager = AlertManager()

        let latestVersionManager = LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            api: api,
            externalResourceServer: externalResourceServer
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

        Logger.loggerBackend = sessionManager

        let parra = ParraInternal(
            authenticationMethod: authenticationMethod,
            configuration: configuration,
            appState: appState,
            authState: authState,
            dataManager: dataManager,
            syncManager: syncManager,
            authService: authService,
            sessionManager: sessionManager,
            api: api,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager,
            containerRenderer: containerRenderer,
            alertManager: alertManager,
            modalScreenManager: modalScreenManager
        )

        apiResourceServer.delegate = parra
        syncManager.delegate = parra

        return parra
    }
}
