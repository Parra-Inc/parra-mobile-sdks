//
//  MockedParraTestCase.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

@MainActor
class MockedParraTestCase: XCTestCase {
    internal var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra(state: .initialized)
    }

    override func tearDown() async throws {
        try await mockParra.tearDown()

        mockParra = nil
    }
}
