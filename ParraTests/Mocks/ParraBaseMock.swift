//
//  ParraBaseMock.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/9/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

private let logger = Logger(
    bypassEventCreation: true,
    category: "Parra Mock Base"
)

class ParraBaseMock: XCTestCase {
    // MARK: - Public

    public var baseStorageDirectory: URL {
        return directoryPath(for: testRun)
    }

    // MARK: - Internal

    override func setUp() async throws {
        try await super.setUp()

        try createBaseDirectory()
    }

    override func tearDown() async throws {
        try await super.tearDown()

        // Clean up data created by tests
        deleteBaseDirectory()
    }

    func directoryName(for testRun: XCTestRun) -> String {
        return "Testing \(testRun.test.name)"
    }

    func directoryPath(for testRun: XCTestRun?) -> URL {
        let testDirectory: String = if let testRun {
            directoryName(for: testRun)
        } else {
            "test-run-\(UUID().uuidString)"
        }

        return ParraDataManager.Base.applicationSupportDirectory
            .appendDirectory(testDirectory)
    }

    func createBaseDirectory() throws {
        deleteBaseDirectory()
        try FileManager.default.safeCreateDirectory(at: baseStorageDirectory)
    }

    func deleteBaseDirectory() {
        let fileManager = FileManager.default

        do {
            if try fileManager.safeDirectoryExists(at: baseStorageDirectory) {
                if fileManager
                    .isDeletableFile(
                        atPath: baseStorageDirectory
                            .nonEncodedPath()
                    )
                {
                    try fileManager.removeItem(at: baseStorageDirectory)
                } else {
                    logger
                        .warn(
                            "File was not deletable!!! \(baseStorageDirectory.nonEncodedPath())"
                        )
                }
            }
        } catch {
            logger.error("Error removing base storage directory", error)
        }
    }
}
