//
//  ParraBaseMock.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/9/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
@testable import Parra

fileprivate let logger = Logger(bypassEventCreation: true, category: "Parra Mock Base")

@MainActor
class ParraBaseMock: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()

        try createBaseDirectory()
    }

    override func tearDown() async throws {
        try await super.tearDown()

        // Clean up data created by tests
        deleteBaseDirectory()
    }

    public var baseStorageDirectory: URL {
        return directoryPath(for: testRun)
    }

    internal func directoryName(for testRun: XCTestRun) -> String {
        return "Testing \(testRun.test.name)"
    }

    internal func directoryPath(for testRun: XCTestRun?) -> URL {
        let testDirectory: String = if let testRun {
            directoryName(for: testRun)
        } else {
            "test-run-\(UUID().uuidString)"
        }

        return ParraDataManager.Base.applicationSupportDirectory
            .appendDirectory(testDirectory)
    }

    internal func createBaseDirectory() throws {
        deleteBaseDirectory()
        try FileManager.default.safeCreateDirectory(at: baseStorageDirectory)
    }

    internal func deleteBaseDirectory() {
        let fileManager = FileManager.default

        do {
            if try fileManager.safeDirectoryExists(at: baseStorageDirectory) {
                if fileManager.isDeletableFile(atPath: baseStorageDirectory.nonEncodedPath()) {
                    try fileManager.removeItem(at: baseStorageDirectory)
                } else {
                    logger.warn("File was not deletable!!! \(baseStorageDirectory.nonEncodedPath())")
                }
            }
        } catch let error {
            logger.error("Error removing base storage directory", error)
        }
    }
}
