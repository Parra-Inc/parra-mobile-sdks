//
//  DataManagerTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

class DataManagerTests: MockedParraTestCase {
    var dataManager: DataManager!

    override func setUp() async throws {
        try createBaseDirectory()

        dataManager = createMockDataManager()
    }

    override func tearDown() async throws {
        deleteBaseDirectory()

        dataManager = nil
    }

    func testCanRetreiveCredentialAfterUpdatingIt() async throws {
        let credential = ParraCredential(
            token: UUID().uuidString
        )

        await dataManager.updateCredential(
            credential: credential
        )

        let retreived = await dataManager.getCurrentCredential()

        XCTAssertEqual(retreived, credential)
    }
}
