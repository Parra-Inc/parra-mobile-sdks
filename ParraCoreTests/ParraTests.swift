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

@MainActor
class ParraCoreTests: XCTestCase {
    override func setUp() async throws {
        await configureWithRequestResolver { request in
            return (EmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
    }

    override func tearDown() async throws {
        await Parra.deinitialize()
        await Parra.shared.sessionManager.resetSession()
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
}
