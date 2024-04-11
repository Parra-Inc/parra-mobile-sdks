//
//  MockedParraTestCase.swift
//  Tests
//
//  Created by Mick MacCallum on 10/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

class MockedParraTestCase: ParraBaseMock {
    var mockParra: MockParra!

    override func setUp() async throws {
        try await super.setUp()

        mockParra = await createMockParra()
    }

    override func tearDown() async throws {
        if let mockParra {
            try await mockParra.tearDown()
        }

        mockParra = nil

        try await super.tearDown()
    }

    func createMockParra(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        authenticationProvider: ParraAuthenticationProviderFunction? = {
            return UUID().uuidString
        }
    ) async -> MockParra {
        let configuration = ParraConfiguration()

        let mockApiResourceServer = await createMockApiResourceServer(
            appState: appState,
            appConfig: configuration,
            authenticationProvider: authenticationProvider
        )

        let notificationCenter = ParraNotificationCenter()
        let syncState = ParraSyncState()

        let sessionManager = ParraSessionManager(
            dataManager: mockApiResourceServer.dataManager,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            syncState: syncState,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter,
            syncDelay: 0.25
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let alertManager = AlertManager()

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let latestVersionManager = LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            apiResourceServer: mockApiResourceServer.apiResourceServer
        )

        let feedback = ParraFeedback(
            dataManager: ParraFeedbackDataManager(
                dataManager: mockApiResourceServer.dataManager,
                syncManager: syncManager,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder,
                fileManager: .default,
                notificationCenter: notificationCenter
            ),
            apiResourceServer: mockApiResourceServer.apiResourceServer
        )

        Logger.loggerBackend = sessionManager

        let parraInternal = ParraInternal(
            configuration: configuration,
            appState: appState,
            dataManager: mockApiResourceServer.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            notificationCenter: notificationCenter,
            feedback: feedback,
            latestVersionManager: latestVersionManager,
            containerRenderer: containerRenderer,
            alertManager: alertManager,
            modalScreenManager: modalScreenManager
        )

        let parra = Parra(parraInternal: parraInternal)

        mockApiResourceServer.apiResourceServer.delegate = parraInternal
        syncManager.delegate = parraInternal

        await sessionManager.initializeSessions()

        return MockParra(
            parra: parra,
            mockApiResourceServer: mockApiResourceServer,
            dataManager: mockApiResourceServer.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            notificationCenter: notificationCenter,
            appState: appState
        )
    }

    func createMockDataManager() -> ParraDataManager {
        let storageDirectoryName = ParraDataManager.Directory
            .storageDirectoryName
        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                baseUrl: baseStorageDirectory,
                folder: storageDirectoryName,
                fileName: ParraDataManager.Key.userCredentialsKey,
                storeItemsSeparately: false,
                fileManager: .default
            ),
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        let sessionStorageUrl = baseStorageDirectory
            .appendFilename(storageDirectoryName)
            .appendFilename("sessions")

        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let sessionStorage = SessionStorage(
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: .default
            ),
            sessionJsonEncoder: .parraEncoder,
            eventJsonEncoder: .spaceOptimizedEncoder
        )

        return ParraDataManager(
            baseDirectory: baseStorageDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )
    }

    func createMockApiResourceServer(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        appConfig: ParraConfiguration = .init(),
        authenticationProvider: ParraAuthenticationProviderFunction?
    ) async -> MockApiResourceServer {
        let dataManager = createMockDataManager()

        let urlSession = MockURLSession(testCase: self)
        let configuration = ServerConfiguration(
            urlSession: urlSession,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        let apiResourceServer = ApiResourceServer(
            appState: appState,
            appConfig: appConfig,
            dataManager: dataManager,
            configuration: configuration
        )

        apiResourceServer.updateAuthenticationProvider(authenticationProvider)

        return MockApiResourceServer(
            apiResourceServer: apiResourceServer,
            dataManager: dataManager,
            urlSession: urlSession,
            appState: appState
        )
    }

    func createLatestVersionManagerMock(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        appConfig: ParraConfiguration = .init(),
        authenticationProvider: ParraAuthenticationProviderFunction?
    ) async -> LatestVersionManager {
        let configuration = ParraConfiguration()
        let notificationCenter = ParraNotificationCenter()

        let mockApiResourceServer = await createMockApiResourceServer(
            appState: appState,
            appConfig: configuration,
            authenticationProvider: authenticationProvider
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let alertManager = AlertManager()

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            apiResourceServer: mockApiResourceServer.apiResourceServer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        return LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            apiResourceServer: mockApiResourceServer.apiResourceServer
        )
    }
}
