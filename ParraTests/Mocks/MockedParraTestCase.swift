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
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString
    ) async -> MockParra {
//        await state.setTenantId(tenantId)
//        await state.setApplicationId(applicationId)

        let configuration = ParraConfiguration(options: [])

        let mockNetworkManager = await createMockNetworkManager(
            appState: .init(tenantId: tenantId, applicationId: applicationId),
            authenticationProvider: nil // TODO: TMP
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

        // Reset the singleton. This is a bit of a problem because there are some
        // places internally within the SDK that may access it, but this will at least
        // prevent an uncontroller new instance from being lazily created on first access.

        // TODO: SwiftUI
//        Parra.setSharedInstance(parra: parra)

//        if await state.isInitialized() {
//            await state.registerModule(module: parra)
//            await sessionManager.initializeSessions()
//        }

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
        appState: ParraAppState = ParraAppState(
            tenantId: UUID().uuidString,
            applicationId: UUID().uuidString
        ),
        authenticationProvider: ParraAuthenticationProviderFunction? = nil
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

//        if await state.isInitialized() {
//            await networkManager.updateAuthenticationProvider(
//                authenticationProvider ?? {
//                    return UUID().uuidString
//                }
//            )
//        }

        return MockParraNetworkManager(
            networkManager: networkManager,
            dataManager: dataManager,
            urlSession: urlSession,
            appState: appState
        )
    }
}
