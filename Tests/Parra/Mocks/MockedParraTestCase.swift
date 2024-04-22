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
        authState: ParraAuthState = .init(),
        authenticationProvider: @escaping ParraTokenProvider = {
            return UUID().uuidString
        }
    ) async -> MockParra {
        let configuration = ParraConfiguration()
        let dataManager = createMockDataManager()

        let (
            mockApiResourceServer,
            mockAuthServer,
            mockExternalResourceServer
        ) = await createMockResourceServers(
            appState: appState,
            appConfig: configuration,
            authenticationProvider: authenticationProvider,
            dataManager: dataManager
        )

        let notificationCenter = ParraNotificationCenter.default
        let syncState = ParraSyncState()

        let api = API(
            appState: appState,
            apiResourceServer: mockApiResourceServer.resourceServer
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            api: api,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            syncState: syncState,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let alertManager = AlertManager()

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let latestVersionManager = LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            api: api,
            externalResourceServer: mockExternalResourceServer.resourceServer
        )

        let authService = AuthService(
            oauth2Service: OAuth2Service(
                clientId: appState.applicationId,
                tenantId: appState.tenantId,
                authServer: mockAuthServer.resourceServer
            ),
            dataManager: dataManager,
            authServer: mockAuthServer.resourceServer,
            authenticationMethod: .custom(tokenProvider: authenticationProvider)
        )

        let feedback = ParraFeedback(
            dataManager: ParraFeedbackDataManager(
                dataManager: dataManager,
                syncManager: syncManager,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder,
                fileManager: .default,
                notificationCenter: notificationCenter
            ),
            api: api,
            apiResourceServer: mockApiResourceServer.resourceServer
        )

        Logger.loggerBackend = sessionManager

        let parraInternal = ParraInternal(
            authenticationMethod: .custom(
                tokenProvider: authenticationProvider
            ),
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

        let parra = Parra(parraInternal: parraInternal)

        mockApiResourceServer.resourceServer.delegate = parraInternal
        syncManager.delegate = parraInternal

        return MockParra(
            parra: parra,
            mockApiResourceServer: mockApiResourceServer,
            mockAuthServer: mockAuthServer,
            mockExternalResource: mockExternalResourceServer,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            apiResourceServer: mockApiResourceServer.resourceServer,
            notificationCenter: notificationCenter,
            appState: appState
        )
    }

    func createMockDataManager() -> DataManager {
        let storageDirectoryName = DataManager.Directory
            .storageDirectoryName
        let credentialStorageModule = ParraStorageModule<ParraUser>(
            dataStorageMedium: .fileSystem(
                baseUrl: baseStorageDirectory,
                folder: storageDirectoryName,
                fileName: DataManager.Key.userCredentialsKey,
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

        return DataManager(
            baseDirectory: baseStorageDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )
    }

    func createMockResourceServers(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        appConfig: ParraConfiguration = .init(),
        authenticationProvider: @escaping ParraTokenProvider,
        dataManager: DataManager
    ) async -> (
        api: MockResourceServer<ApiResourceServer>,
        auth: MockResourceServer<AuthServer>,
        external: MockResourceServer<ExternalResourceServer>
    ) {
        let urlSession = MockURLSession(testCase: self)
        let configuration = ServerConfiguration(
            urlSession: urlSession,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        let authServer = AuthServer(
            appState: appState,
            appConfig: appConfig,
            configuration: configuration
        )

        let authService = AuthService(
            oauth2Service: OAuth2Service(
                clientId: appState.applicationId,
                tenantId: appState.tenantId,
                authServer: authServer
            ),
            dataManager: dataManager,
            authServer: authServer,
            authenticationMethod: .custom(tokenProvider: authenticationProvider)
        )

        let apiResourceServer = ApiResourceServer(
            authService: authService,
            appState: appState,
            appConfig: appConfig,
            dataManager: dataManager,
            configuration: configuration
        )

        let externalResourceServer = ExternalResourceServer(
            configuration: configuration
        )

        return (
            MockResourceServer(
                resourceServer: apiResourceServer,
                dataManager: dataManager,
                urlSession: urlSession,
                appState: appState
            ),
            MockResourceServer(
                resourceServer: authServer,
                dataManager: dataManager,
                urlSession: urlSession,
                appState: appState
            ),
            MockResourceServer(
                resourceServer: externalResourceServer,
                dataManager: dataManager,
                urlSession: urlSession,
                appState: appState
            )
        )
    }

    func createLatestVersionManagerMock(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        appConfig: ParraConfiguration = .init(),
        authenticationProvider: @escaping ParraTokenProvider
    ) async -> LatestVersionManager {
        let configuration = ParraConfiguration()
        let notificationCenter = ParraNotificationCenter()
        let dataManager = createMockDataManager()

        let (
            mockApiResourceServer,
            _,
            mockExternalResourceServer
        ) = await createMockResourceServers(
            appState: appState,
            appConfig: configuration,
            authenticationProvider: authenticationProvider,
            dataManager: dataManager
        )

        let containerRenderer = ContainerRenderer(
            configuration: configuration
        )

        let alertManager = AlertManager()

        let modalScreenManager = ModalScreenManager(
            containerRenderer: containerRenderer,
            configuration: configuration,
            notificationCenter: notificationCenter
        )

        let api = API(
            appState: appState,
            apiResourceServer: mockApiResourceServer.resourceServer
        )

        return LatestVersionManager(
            configuration: configuration,
            modalScreenManager: modalScreenManager,
            alertManager: alertManager,
            api: api,
            externalResourceServer: mockExternalResourceServer.resourceServer
        )
    }
}
