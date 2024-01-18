//
//  FileManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import Parra

class FileManagerTests: MockedParraTestCase {
    let fileManager = FileManager.default

    override func setUp() async throws {
        // Specifically not calling super to avoid Parra mocks from being created.

        try fileManager.safeCreateDirectory(at: baseStorageDirectory)
    }

    func testSafeCreateWhenDirectoryDoesNotExist() throws {
        let dirPath = baseStorageDirectory.appendDirectory("testDir")

        try fileManager.safeCreateDirectory(at: dirPath)

        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(
            atPath: dirPath.path,
            isDirectory: &isDirectory
        )
        
        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }
    
    func testSafeCreateWhenDirectoryExists() throws {
        let dirPath = baseStorageDirectory.appendDirectory("testDir")

        try fileManager.createDirectory(
            at: dirPath,
            withIntermediateDirectories: true
        )
        
        try fileManager.safeCreateDirectory(at: dirPath)

        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(
            atPath: dirPath.path,
            isDirectory: &isDirectory
        )
        
        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }
    
    func testSafeCreateWhenFileExistsAtDirectoryPath() throws {
        let filePath = baseStorageDirectory.appendFilename("testFile.txt")

        fileManager.createFile(atPath: filePath.path, contents: nil)

        XCTAssertThrowsError(try fileManager.safeCreateDirectory(at: filePath))
    }
}
