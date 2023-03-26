//
//  ParraCoreTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/13/22.
//

import XCTest
@testable import ParraCore

class FakeModule: ParraModule {
    static var name: String = "FakeModule"
    
    func hasDataToSync() async -> Bool {
        return true
    }
    
    func synchronizeData() async {
        try! await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

class ParraCoreTests: XCTestCase {
    override func setUp() async throws {
        Parra.Initializer.isInitialized = false

        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }

//        let dataManager = ParraDataManager()
//        await dataManager.updateCredential(credential: ParraCredential(token: UUID().uuidString))
//
//        let networkManager = ParraNetworkManager(
//            dataManager: dataManager,
//            urlSession: URLSession.shared
//        )
//
//        let sessionManager = ParraSessionManager(
//            dataManager: dataManager,
//            networkManager: networkManager
//        )
//
//        let syncManager = ParraSyncManager(
//            networkManager: networkManager,
//            sessionManager: sessionManager
//        )
//
//        Parra.shared = Parra(
//            dataManager: dataManager,
//            syncManager: syncManager,
//            sessionManager: sessionManager,
//            networkManager: networkManager
//        )
//
//        Parra.Initializer.isInitialized = false
    }

    override func tearDown() async throws {
//        Parra.shared = nil
    }

    func testModulesCanBeRegistered() throws {
        let module = FakeModule()

        Parra.registerModule(module: module)
        
        XCTAssertTrue(Parra.hasRegisteredModule(module: FakeModule.self))
        XCTAssert(Parra.registeredModules.keys.contains(FakeModule.name))
    }
    
    func testModuleRegistrationIsDeduplicated() throws {
        let module = FakeModule()
        
        Parra.registerModule(module: module)
        Parra.registerModule(module: module)

        XCTAssertTrue(Parra.hasRegisteredModule(module: FakeModule.self))
        XCTAssert(Parra.registeredModules.keys.contains(FakeModule.name))
        XCTAssertEqual(Parra.registeredModules.count, 2)
    }
    
    func testLogout() async throws {
        let exp = expectation(description: "expecting logout completion handler")
        Parra.logout {
            exp.fulfill()
        }
        
        await waitForExpectations(timeout: 3.0)

        let currentCredential = await Parra.shared.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }

    func testTriggerSyncDoesNothingWithoutAuthProvider() async throws {
        let exp  = expectation(forNotification: Parra.syncDidBeginNotification, object: nil)
        exp.isInverted = true
        Parra.triggerSync {}

        wait(for: [exp], timeout: 1.0)
    }

    func testTriggerSync() async throws {
        Parra.initialize(authProvider: .default(tenantId: "tenant", authProvider: {
            return UUID().uuidString
        }))

        let exp = XCTNSNotificationExpectation(name: Parra.syncDidBeginNotification)

        Parra.triggerSync {}

        wait(for: [exp], timeout: 3.0)
    }
}
