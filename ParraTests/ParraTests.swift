//
//  ParraTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/13/22.
//

import XCTest
@testable import Parra

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
class ParraTests: XCTestCase {
    override func setUp() async throws {
        await configureWithRequestResolver { request in
            return (EmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
    }

    override func tearDown() async throws {
        await Parra.deinitialize()
        await Parra.shared.sessionManager.resetSession()
    }

    func testModulesCanBeRegistered() async throws {
        let module = FakeModule()

        await ParraGlobalState.shared.registerModule(module: module)

        let hasRegistered = await ParraGlobalState.shared.hasRegisteredModule(module: module)
        XCTAssertTrue(hasRegistered)
        let modules = await ParraGlobalState.shared.getAllRegisteredModules()
        XCTAssert(modules.keys.contains(FakeModule.name))
    }

    func testModuleRegistrationIsDeduplicated() async throws {
        let module = FakeModule()

        let checkBeforeRegister = await ParraGlobalState.shared.hasRegisteredModule(module: module)
        XCTAssertFalse(checkBeforeRegister)

        let previous = await ParraGlobalState.shared.getAllRegisteredModules()

        await ParraGlobalState.shared.registerModule(module: module)
        await ParraGlobalState.shared.registerModule(module: module)

        let hasRegistered = await ParraGlobalState.shared.hasRegisteredModule(module: module)
        XCTAssertTrue(hasRegistered)

        let modules = await ParraGlobalState.shared.getAllRegisteredModules()
        XCTAssert(modules.keys.contains(FakeModule.name))
        XCTAssertEqual(modules.count, previous.count + 1)
    }
    
    func testLogout() async throws {
        await Parra.logout()

        let currentCredential = await Parra.shared.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }
}
