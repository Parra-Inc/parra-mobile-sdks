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
        try! await Task.sleep(for: 0.25)
    }
}

@MainActor
class ParraTests: MockedParraTestCase {
    private var fakeModule: FakeModule?

    override func tearDown() async throws {
        if let fakeModule {
            await mockParra.parra.state.unregisterModule(module: fakeModule)
        }

        try await super.tearDown()
    }

    func testModulesCanBeRegistered() async throws {
        fakeModule = FakeModule()

        await mockParra.parra.state.registerModule(module: fakeModule!)

        let hasRegistered = await mockParra.parra.state.hasRegisteredModule(
            module: fakeModule!
        )
        
        XCTAssertTrue(hasRegistered)
        
        let modules = await mockParra.parra.state.getAllRegisteredModules()

        XCTAssert(modules.contains(where: { testModule in
            return type(of: fakeModule!).name == type(of: testModule).name
        }))
    }

    func testModuleRegistrationIsDeduplicated() async throws {
        fakeModule = FakeModule()

        let checkBeforeRegister = await mockParra.parra.state.hasRegisteredModule(
            module: fakeModule!
        )
        XCTAssertFalse(checkBeforeRegister)

        let previous = await mockParra.parra.state.getAllRegisteredModules()

        await mockParra.parra.state.registerModule(module: fakeModule!)
        await mockParra.parra.state.registerModule(module: fakeModule!)

        let hasRegistered = await mockParra.parra.state.hasRegisteredModule(
            module: fakeModule!
        )
        XCTAssertTrue(hasRegistered)

        let modules = await mockParra.parra.state.getAllRegisteredModules()
        XCTAssert(modules.contains(where: { testModule in
            return type(of: fakeModule!).name == type(of: testModule).name
        }))
        XCTAssertEqual(modules.count, previous.count + 1)
    }

    func testLogout() async throws {
        await mockParra.parra.logout()

        let currentCredential = await mockParra.dataManager.getCurrentCredential()
        XCTAssertNil(currentCredential)
    }
}
