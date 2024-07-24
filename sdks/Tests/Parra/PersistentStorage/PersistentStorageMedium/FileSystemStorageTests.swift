//
//  FileSystemStorageTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/17/22.
//

@testable import Parra
import XCTest

class FileSystemStorageTests: ParraBaseMock {
    // MARK: - Internal

    override func setUp() async throws {
        try await super.setUp()

        fileSystemStorage = FileSystemStorage(
            baseUrl: baseStorageDirectory,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder(),
            fileManager: fileManager
        )
    }

    func testReadDoesNotExist() async throws {
        let file: [String: String]? = try fileSystemStorage.read(
            name: "file.txt"
        )

        XCTAssertNil(file)
    }

    func testReadFileDoesExist() async throws {
        let fileName = "file.txt"
        let filePath = baseStorageDirectory.appendingPathComponent(
            fileName,
            isDirectory: false
        )

        let data = [
            "aKey": "aValue"
        ]

        try fileManager.createFile(
            atPath: filePath.path,
            contents: JSONEncoder().encode(data)
        )

        let file: [String: String]? = try fileSystemStorage.read(
            name: fileName
        )

        XCTAssertNotNil(file)
        XCTAssertEqual(file, data)
    }

    func testWriteFileExists() async throws {
        let name = "file2.dat"
        let filePath = baseStorageDirectory.appendingPathComponent(
            name,
            isDirectory: false
        )
        let data = [
            "key": "val"
        ]

        try fileSystemStorage.write(
            name: name,
            value: data
        )

        let fileData = try Data(contentsOf: filePath)
        let file = try JSONDecoder().decode(
            [String: String].self,
            from: fileData
        )

        XCTAssertEqual(file, data)
    }

    func testDeleteFileDoesNotExist() async throws {
        let name = "file3.dat"
        let filePath = baseStorageDirectory.appendingPathComponent(
            name,
            isDirectory: false
        )
        let data = [
            "key": "val"
        ]

        try fileSystemStorage.write(
            name: name,
            value: data
        )

        try fileSystemStorage.delete(name: name)

        XCTAssertFalse(fileManager.fileExists(atPath: filePath.path))
    }

    // MARK: - Private

    private let fileManager = FileManager.default
    private var fileSystemStorage: FileSystemStorage!
}
