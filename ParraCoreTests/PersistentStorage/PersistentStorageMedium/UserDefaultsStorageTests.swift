//
//  UserDefaultsStorageTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import ParraCore

class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults.standard
    private var userDefaultsStorage: UserDefaultsStorage!
    
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
        let data: [String: String] = [
            "aKey": "aValue"
        ]

        userDefaults.set(try JSONEncoder().encode(data), forKey: key)
        
        let readData: [String: String]? = try await userDefaultsStorage.read(
            name: key
        )

        XCTAssertNotNil(readData)
        XCTAssertEqual(readData, data)
    }

    func testWriteFileExists() async throws {
        let key = "key3"
        let data: [String: String] = [
            "key": "val"
        ]
        
        try await userDefaultsStorage.write(
            name: key,
            value: data
        )

        let readData = userDefaults.value(forKey: key) as? Data
        XCTAssertNotNil(readData)
        XCTAssertEqual(data, try JSONDecoder().decode([String: String].self, from: readData!))
    }

    func testDeleteFileDoesNotExist() async throws {
        let key = "key4"
        let data: [String: String] = [
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
}
