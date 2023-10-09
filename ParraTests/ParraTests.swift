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
    
    func hasDataToSync(since date: Date?) async -> Bool {
        return true
    }
    
    func synchronizeData() async {
        try! await Task.sleep(for: 1.0)
    }
}

@MainActor
class ParraTests: MockedParraTestCase {

    func testModulesCanBeRegistered() async throws {
        let module = FakeModule()

        await mockParra.parra.state.registerModule(module: module)

        let hasRegistered = await mockParra.parra.state.hasRegisteredModule(module: module)
        XCTAssertTrue(hasRegistered)
        let modules = await mockParra.parra.state.getAllRegisteredModules()
        XCTAssert(modules.contains(where: { testModule in
            return type(of: module).name == type(of: testModule).name
        }))
    }

    func testModuleRegistrationIsDeduplicated() async throws {
        let module = FakeModule()

        let checkBeforeRegister = await mockParra.parra.state.hasRegisteredModule(module: module)
        XCTAssertFalse(checkBeforeRegister)

        let previous = await mockParra.parra.state.getAllRegisteredModules()

        await mockParra.parra.state.registerModule(module: module)
        await mockParra.parra.state.registerModule(module: module)

        let hasRegistered = await mockParra.parra.state.hasRegisteredModule(module: module)
        XCTAssertTrue(hasRegistered)

        let modules = await mockParra.parra.state.getAllRegisteredModules()
        XCTAssert(modules.contains(where: { testModule in
            return type(of: module).name == type(of: testModule).name
        }))
        XCTAssertEqual(modules.count, previous.count + 1)
    }

    func testLogout() async throws {
        await mockParra.parra.logout()

        let currentCredential = await mockParra.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }
}
