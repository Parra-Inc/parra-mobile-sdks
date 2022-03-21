//
//  ParraDataManagerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import ParraCore

class ParraDataManagerTests: XCTestCase {
    var parraDataManager: ParraDataManager!
    
    override func setUpWithError() throws {
        parraDataManager = ParraDataManager()
    }

    override func tearDownWithError() throws {
        parraDataManager = nil
    }

    func testCanRetreiveCredentialAfterUpdatingIt() async throws {
        let credential = ParraCredential(
            token: UUID().uuidString
        )
        
        await parraDataManager.updateCredential(
            credential: credential
        )
        
        let retreived = await parraDataManager.getCurrentCredential()
        
        XCTAssertEqual(retreived, credential)
    }
}
