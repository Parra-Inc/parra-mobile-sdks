//
//  ParraSessionManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

@MainActor
final class ParraSessionManagerTests: XCTestCase {
    private var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra(state: .initialized)
    }

    override func tearDown() async throws {
        mockParra = nil
    }

    func testSessionStartsOnInit() async throws {
        let currentSession = await mockParra.sessionManager.currentSession
        XCTAssertNotNil(currentSession)
    }

    func testSessionsStartInResponseToEvents() async throws {
//        mockParra.sessionManager.
    }
}
