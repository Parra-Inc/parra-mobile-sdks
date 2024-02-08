//
//  ParraDataManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

@MainActor
class ParraDataManagerTests: MockedParraTestCase {
    var parraDataManager: ParraDataManager!

    override func setUp() async throws {
        try createBaseDirectory()

        parraDataManager = createMockDataManager()
    }

    override func tearDown() async throws {
        deleteBaseDirectory()

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
