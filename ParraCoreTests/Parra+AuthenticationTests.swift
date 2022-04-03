//
//  Parra+AuthenticationTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/24/22.
//

import XCTest
@testable import ParraCore

class ParraAuthenticationTests: XCTestCase {

    override func setUpWithError() throws {
        let dataManager = ParraDataManager()
        
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: URLSession.shared
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

//    func testSetAuthenticationProvider() async throws {
//        let providerBefore = await Parra.shared.networkManager.authenticationProvider
//        
//        XCTAssertNil(providerBefore)
//
//        Parra.setAuthenticationProvider { () async throws -> ParraCredential in
//            return .init(token: UUID().uuidString)
//        }
//        
//        // Need to mock network manager
//        XCTWaiter.wait(for: [], timeout: 1.0)
//        
//        let providerAfter = await Parra.shared.networkManager.authenticationProvider
//        
//        XCTAssertNotNil(providerAfter)
//    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
