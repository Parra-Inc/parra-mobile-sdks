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
        let user = ParraUser(
            credential: ParraUser.Credential.basic(UUID().uuidString),
            info: ParraUser.Info()
        )

        await dataManager.updateCurrentUser(user)

        let retreived = await dataManager.getCurrentUser()

        XCTAssertEqual(retreived, user)
    }
}
