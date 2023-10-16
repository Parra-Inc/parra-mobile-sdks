//
//  MockedParraTestCase.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

@MainActor
class MockedParraTestCase: ParraBaseMock {
    internal var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra(
            state: .initialized
        )
    }

    override func tearDown() async throws {
        if let mockParra {
            try await mockParra.tearDown()
        }

        // Clean up data created by tests
        let fileManager = FileManager.default
        if try fileManager.safeDirectoryExists(at: baseStorageDirectory) {
            try fileManager.removeItem(at: baseStorageDirectory)
        }

        mockParra = nil
    }

    func createMockParra(
        state: ParraState = ParraState(),
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString
    ) async -> MockParra {

        var newConfig = ParraConfiguration(options: [])
        newConfig.setTenantId(tenantId)
        newConfig.setApplicationId(applicationId)

        let mockNetworkManager = await createMockNetworkManager(
            state: state,
            tenantId: tenantId,
            applicationId: applicationId
        )

        let notificationCenter = ParraNotificationCenter()
        let syncState = ParraSyncState()

        let configState = ParraConfigState()
        await configState.updateState(newConfig)

        let sessionManager = ParraSessionManager(
            dataManager: mockNetworkManager.dataManager,
            networkManager: mockNetworkManager.networkManager,
            loggerOptions: ParraConfigState.defaultState.loggerOptions
        )

        let syncManager = ParraSyncManager(
            state: state,
            syncState: syncState,
            networkManager: mockNetworkManager.networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter,
            syncDelay: 5.0
        )

        Logger.loggerBackend = sessionManager

        let parra = Parra(
            state: state,
            configState: configState,
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

        let storageDirectoryName = ParraDataManager.Directory.storageDirectoryName
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
            .safeAppendPathComponent(storageDirectoryName)
            .safeAppendPathComponent("sessions")

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
        let configState = ParraConfigState.initialized(
            tenantId: tenantId,
            applicationId: applicationId
        )

        let networkManager = ParraNetworkManager(
            state: state,
            configState: configState,
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
