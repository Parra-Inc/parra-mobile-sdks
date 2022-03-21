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
        
    }
}

class ParraCoreTests: XCTestCase {

    override func setUpWithError() throws {
        let dataManager = ParraDataManager()
        
        let networkManager = ParraNetworkManager(
            dataManager: dataManager
        )
        
        let syncManager = ParraFeedbackSyncManager(
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
        
        XCTAssertTrue(Parra.hasRegisteredModule(module: module))
        XCTAssert(Parra.registeredModules.keys.contains(FakeModule.name))
    }
}
