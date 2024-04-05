//
//  UserDefaultsStorageTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/17/22.
//

@testable import Parra
import XCTest

class UserDefaultsStorageTests: XCTestCase {
    // MARK: - Internal

    override func setUpWithError() throws {
        userDefaultsStorage = UserDefaultsStorage(
            userDefaults: userDefaults,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder()
        )
    }

    func testReadDoesNotExist() async throws {
        let file: [String: String]? = try await userDefaultsStorage.read(
            name: "key1"
        )

        XCTAssertNil(file)
    }

    func testReadFileDoesExist() async throws {
        let key = "key2"
        let data = [
            "aKey": "aValue"
        ]

        try userDefaults.set(JSONEncoder().encode(data), forKey: key)

        let readData: [String: String]? = try await userDefaultsStorage.read(
            name: key
        )

        XCTAssertNotNil(readData)
        XCTAssertEqual(readData, data)
    }

    func testWriteFileExists() async throws {
        let key = "key3"
        let data = [
            "key": "val"
        ]

        try await userDefaultsStorage.write(
            name: key,
            value: data
        )

        let readData = userDefaults.value(forKey: key) as? Data
        XCTAssertNotNil(readData)
        XCTAssertEqual(
            data,
            try JSONDecoder().decode([String: String].self, from: readData!)
        )
    }

    func testDeleteFileDoesNotExist() async throws {
        let key = "key4"
        let data = [
            "key": "val"
        ]

        try await userDefaultsStorage.write(
            name: key,
            value: data
        )

        try await userDefaultsStorage.delete(
            name: key
        )

        XCTAssertNil(userDefaults.value(forKey: key))
    }

    // MARK: - Private

    private let userDefaults = UserDefaults.standard
    private var userDefaultsStorage: UserDefaultsStorage!
}
