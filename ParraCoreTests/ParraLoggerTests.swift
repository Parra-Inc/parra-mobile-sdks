//
//  ParraLoggerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import ParraCore

class ParraLoggerTests: XCTestCase {

    func testLogLevels() throws {
        XCTAssert(ParraLogLevel.error > .warn)
        XCTAssert(ParraLogLevel.warn > .info)
        XCTAssert(ParraLogLevel.info > .verbose)
    }
}
