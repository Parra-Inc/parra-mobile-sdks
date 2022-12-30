//
//  FileSystemStorageTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import ParraCore

class FileSystemStorageTests: XCTestCase {

    private let fileManager = FileManager.default
    private var fileSystemStorage: FileSystemStorage!
    private let baseUrl = ParraDataManager.Base.applicationSupportDirectory.appendingPathComponent("files", isDirectory: true)
    
    override func setUpWithError() throws {
        try deleteDirectoriesInApplicationSupport()

        fileSystemStorage = FileSystemStorage(
            baseUrl: baseUrl,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder()
        )
    }
    
    override func tearDownWithError() throws {
        try deleteDirectoriesInApplicationSupport()
    }

    func testReadDoesNotExist() async throws {
        let file: [String: String]? = try await fileSystemStorage.read(
            name: "file.txt"
        )
        
        XCTAssertNil(file)
    }
    
    func testReadFileDoesExist() async throws {
        let fileName = "file.txt"
        let filePath = baseUrl.appendingPathComponent(fileName, isDirectory: false)
        
        let data: [String: String] = [
            "aKey": "aValue"
        ]
        
        fileManager.createFile(
            atPath: filePath.path,
            contents: try JSONEncoder().encode(data)
        )
        
        let file: [String: String]? = try await fileSystemStorage.read(
            name: fileName
        )
        
        XCTAssertNotNil(file)
        XCTAssertEqual(file, data)
    }

    func testWriteFileExists() async throws {
        let name = "file2.dat"
        let filePath = baseUrl.appendingPathComponent(name, isDirectory: false)
        let data: [String: String] = [
            "key": "val"
        ]
        
        try await fileSystemStorage.write(
            name: name,
            value: data
        )
        
        let fileData = try Data(contentsOf: filePath)
        let file = try JSONDecoder().decode([String: String].self, from: fileData)
        
        XCTAssertEqual(file, data)
    }
    
    func testDeleteFileDoesNotExist() async throws {
        let name = "file3.dat"
        let filePath = baseUrl.appendingPathComponent(name, isDirectory: false)
        let data: [String: String] = [
            "key": "val"
        ]

        try await fileSystemStorage.write(
            name: name,
            value: data
        )

        try await fileSystemStorage.delete(name: name)
        
        XCTAssertFalse(fileManager.fileExists(atPath: filePath.path))
    }
}
