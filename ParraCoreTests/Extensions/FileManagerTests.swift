//
//  FileManagerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import ParraCore

let testPath = ParraDataManager.Base.applicationSupportDirectory.appendingPathComponent("testDir", isDirectory: true)

class FileManagerTests: XCTestCase {
    let fileManager = FileManager.default

    override func setUpWithError() throws {
        try deleteDirectoriesInApplicationSupport()
    }
    
    func testSafeCreateWhenDirectoryDoesNotExist() throws {
        try fileManager.safeCreateDirectory(at: testPath)
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(
            atPath: testPath.path,
            isDirectory: &isDirectory
        )
        
        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }
    
    func testSafeCreateWhenDirectoryExists() throws {
        try fileManager.createDirectory(
            at: testPath,
            withIntermediateDirectories: true
        )
        
        try fileManager.safeCreateDirectory(at: testPath)
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(
            atPath: testPath.path,
            isDirectory: &isDirectory
        )
        
        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }
    
    func testSafeCreateWhenFileExistsAtDirectoryPath() throws {
        fileManager.createFile(atPath: testPath.path, contents: nil)
        
        XCTAssertThrowsError(try fileManager.safeCreateDirectory(at: testPath))
    }
}
