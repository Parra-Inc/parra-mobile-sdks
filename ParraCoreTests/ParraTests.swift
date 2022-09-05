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
    
    func triggerSync() async {
        try! await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

class ParraCoreTests: XCTestCase {
    override func setUp() async throws {
        let dataManager = ParraDataManager()
        await dataManager.updateCredential(credential: ParraCredential(token: UUID().uuidString))
        
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: URLSession.shared
        )
        
        let syncManager = ParraSyncManager(
            networkManager: networkManager
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
    }

    override func tearDownWithError() throws {
        Parra.shared = nil
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
        XCTAssertEqual(Parra.registeredModules.count, 1)
    }
    
    func testLogout() async throws {
        let exp = expectation(description: "logout completion")
        Parra.logout {
            exp.fulfill()
        }
        
        await waitForExpectations(timeout: 0.1)
        
        let currentCredential = await Parra.shared.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }
    
    func testTriggerSync() async throws {
        expectation(forNotification: Parra.syncDidBeginNotification, object: nil)
        Parra.triggerSync {}
        
        await waitForExpectations(timeout: 0.1)
    }
}
