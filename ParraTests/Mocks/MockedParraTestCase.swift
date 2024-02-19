//
//  MockedParraTestCase.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

@MainActor
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
        let configuration = ParraConfiguration(options: [])

        let mockNetworkManager = await createMockNetworkManager(
            appState: appState,
            authenticationProvider: authenticationProvider
        )

        let notificationCenter = ParraNotificationCenter()
        let syncState = ParraSyncState()

        let sessionManager = ParraSessionManager(
            dataManager: mockNetworkManager.dataManager,
            networkManager: mockNetworkManager.networkManager,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            syncState: syncState,
            networkManager: mockNetworkManager.networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter,
            syncDelay: 0.25
        )

        let feedback = ParraFeedback(
            dataManager: ParraFeedbackDataManager(
                dataManager: mockNetworkManager.dataManager,
                syncManager: syncManager,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder,
                fileManager: .default,
                notificationCenter: notificationCenter
            ),
            networkManager: mockNetworkManager.networkManager
        )

        Logger.loggerBackend = sessionManager

        let parra = Parra(
            configuration: configuration,
            dataManager: mockNetworkManager.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: mockNetworkManager.networkManager,
            notificationCenter: notificationCenter,
            feedback: feedback
        )

        mockNetworkManager.networkManager.delegate = parra
        syncManager.delegate = parra

        await sessionManager.initializeSessions()

        return MockParra(
            parra: parra,
            mockNetworkManager: mockNetworkManager,
            dataManager: mockNetworkManager.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: mockNetworkManager.networkManager,
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

    func createMockNetworkManager(
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        authenticationProvider: ParraAuthenticationProviderFunction?
    ) async -> MockParraNetworkManager {
        let dataManager = createMockDataManager()

        let urlSession = MockURLSession(testCase: self)
        let configuration = ParraInstanceNetworkConfiguration(
            urlSession: urlSession,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        let networkManager = ParraNetworkManager(
            appState: appState,
            dataManager: dataManager,
            configuration: configuration
        )

        networkManager.updateAuthenticationProvider(authenticationProvider)

        return MockParraNetworkManager(
            networkManager: networkManager,
            dataManager: dataManager,
            urlSession: urlSession,
            appState: appState
        )
    }
}
