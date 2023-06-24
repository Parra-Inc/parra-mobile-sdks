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
        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }

        Parra.initialize(authProvider: .default(tenantId: "tenant", authProvider: {
            return UUID().uuidString
        }))
    }

    override func tearDown() async throws {
        Parra.Initializer.isInitialized = false
    }

    func testModulesCanBeRegistered() throws {
        let module = FakeModule()

        Parra.registerModule(module: module)
        
        XCTAssertTrue(Parra.hasRegisteredModule(module: module))
        XCTAssert(Parra.registeredModules.keys.contains(FakeModule.name))
    }
    
    func testModuleRegistrationIsDeduplicated() throws {
        let module = FakeModule()
        
        Parra.registerModule(module: module)
        Parra.registerModule(module: module)

        XCTAssertTrue(Parra.hasRegisteredModule(module: module))
        XCTAssert(Parra.registeredModules.keys.contains(FakeModule.name))
        XCTAssertEqual(Parra.registeredModules.count, 2)
    }
    
    func testLogout() async throws {
        await Parra.logout()

        let currentCredential = await Parra.shared.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }

    func testTriggerSyncDoesNothingWithoutAuthProvider() async throws {
        let exp  = expectation(forNotification: Parra.syncDidBeginNotification, object: nil)
        exp.isInverted = true
        Parra.triggerSync {}

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func testTriggerSync() async throws {
        let notificationExpectation = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: nil,
            notificationCenter: NotificationCenter.default
        )

        await Parra.shared.sessionManager.logEvent("test", params: [String: Any]())
        await Parra.triggerSync()

        await fulfillment(of: [notificationExpectation], timeout: 1.0)
    }
}
