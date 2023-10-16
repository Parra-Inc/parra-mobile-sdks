//
//  ParraBaseMock.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/9/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

@MainActor
class ParraBaseMock: XCTestCase {
    public var baseStorageDirectory: URL {
        let testDirectory: String = if let testRun {
            "Testing \(testRun.test.name) at \(testRun.startDate?.ISO8601Format(.iso8601) ?? "unknown")"
        } else {
            "test-run-\(UUID().uuidString)"
        }

        return ParraDataManager.Path.parraDirectory
            .safeAppendDirectory(testDirectory)
    }
}
