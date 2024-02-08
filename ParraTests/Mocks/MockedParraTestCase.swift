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

        mockParra = await createMockParra(
            state: .initialized
        )
    }

    override func tearDown() async throws {
        if let mockParra {
            try await mockParra.tearDown()
        }

        mockParra = nil

        try await super.tearDown()
    }

    func createMockParra(
        state: ParraState = ParraState(),
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString
    ) async -> MockParra {
        await state.setTenantId(tenantId)
        await state.setApplicationId(applicationId)

        let configuration = ParraConfiguration(options: [])

        let mockNetworkManager = await createMockNetworkManager(
            state: state,
            tenantId: tenantId,
            applicationId: applicationId
        )

        let notificationCenter = ParraNotificationCenter()
        let syncState = ParraSyncState()

        let sessionManager = ParraSessionManager(
            dataManager: mockNetworkManager.dataManager,
            networkManager: mockNetworkManager.networkManager,
            loggerOptions: configuration.loggerOptions
        )

        let syncManager = ParraSyncManager(
            state: state,
            syncState: syncState,
            networkManager: mockNetworkManager.networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter,
            syncDelay: 0.25
        )

        Logger.loggerBackend = sessionManager

        let parra = Parra(
            state: state,
            configuration: configuration,
            dataManager: mockNetworkManager.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: mockNetworkManager.networkManager,
            notificationCenter: notificationCenter
        )

        // Reset the singleton. This is a bit of a problem because there are some
        // places internally within the SDK that may access it, but this will at least
        // prevent an uncontroller new instance from being lazily created on first access.
        Parra.setSharedInstance(parra: parra)

        if await state.isInitialized() {
            await state.registerModule(module: parra)
            await sessionManager.initializeSessions()
        }

        return MockParra(
            parra: parra,
            mockNetworkManager: mockNetworkManager,
            dataManager: mockNetworkManager.dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: mockNetworkManager.networkManager,
            notificationCenter: notificationCenter,
            tenantId: tenantId,
            applicationId: applicationId
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
        state: ParraState = .initialized,
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString,
        authenticationProvider: ParraAuthenticationProviderFunction? = nil
    ) async -> MockParraNetworkManager {
        let dataManager = createMockDataManager()

        let urlSession = MockURLSession(testCase: self)

        await state.setTenantId(tenantId)
        await state.setApplicationId(applicationId)

        let networkManager = ParraNetworkManager(
            state: state,
            dataManager: dataManager,
            urlSession: urlSession,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        if await state.isInitialized() {
            await networkManager.updateAuthenticationProvider(
                authenticationProvider ?? {
                    return UUID().uuidString
                }
            )
        }

        return MockParraNetworkManager(
            networkManager: networkManager,
            dataManager: dataManager,
            urlSession: urlSession,
            tenantId: tenantId,
            applicationId: applicationId
        )
    }
}
