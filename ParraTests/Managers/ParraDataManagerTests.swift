//
//  ParraDataManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import Parra

@MainActor
class ParraDataManagerTests: XCTestCase {
    var parraDataManager: ParraDataManager!
    
    override func setUp() async throws {
        parraDataManager = createMockDataManager()
    }

    override func tearDown() async throws {
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
