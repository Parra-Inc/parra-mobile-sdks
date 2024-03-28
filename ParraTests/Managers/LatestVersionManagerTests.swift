//
//  LatestVersionManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

final class LatestVersionManagerTests: MockedParraTestCase {
    // MARK: - Internal

    override func setUp() async throws {
        try await super.setUp()

        manager = await createLatestVersionManagerMock(
            authenticationProvider: nil
        )
    }

    override func tearDown() async throws {
        try await super.tearDown()

        manager = nil
    }

    func testExample() async throws {
//        let response = try await manager.fetchLatestAppStoreUpdate(
//            for: "com.humblebots.onlyrecipes"
//        )

//        response.resultCount
    }

    // MARK: - Private

    private var manager: LatestVersionManager!
}
