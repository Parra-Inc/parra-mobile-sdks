//
//  ParraStorageModuleTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/17/22.
//

@testable import Parra
import XCTest

private typealias TestDataType = [String: String]

class ParraStorageModuleTests: ParraBaseMock {
    // MARK: - Internal

    var storageModules = [ParraStorageModule<String>]()

    override func setUp() async throws {
        try await super.setUp()

        clearParraUserDefaultsSuite()

        let folder = "storage_modules"
        let file = "storage_data"

        storageModules = [
            .init(
                dataStorageMedium: .memory,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            ),
            .init(
                dataStorageMedium: .fileSystem(
                    baseUrl: baseStorageDirectory,
                    folder: folder,
                    fileName: file,
                    storeItemsSeparately: true,
                    fileManager: .default
                ),
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            ),
            .init(
                dataStorageMedium: .userDefaults(key: file),
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            )
        ]
    }

    override func tearDown() async throws {
        try await super.tearDown()

        clearParraUserDefaultsSuite()
    }

    func testLoadsDataWhenPresent() async throws {
        var data: TestDataType = [:]
        let testKey = "keyyyyFromLoadsData"
        let testValue = "hello"

        data[testKey] = testValue

        for storageModule in storageModules {
            switch storageModule.dataStorageMedium {
            case .memory:
                break
            case .userDefaults:
                let (medium, key) = storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()

                let cache = storageModule.storageCache
                XCTAssertEqual(data, cache)

                let readData = await storageModule.read(name: testKey)
                XCTAssertEqual(readData, testValue)
            case .fileSystem:
                let (medium, key) = storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()

                let cache = storageModule.storageCache
                XCTAssertEqual([:], cache)
            }
        }
    }

    func testLoadsDataWhenNotPresent() async throws {
        for storageModule in storageModules {
            await storageModule.loadData()

            let isLoaded = storageModule.isLoaded
            let medium = storageModule.dataStorageMedium
            XCTAssertTrue(isLoaded, "isLoaded failed for \(medium)")
        }
    }

    func testLoadsDataOnDemandDuringReads() async throws {
        var testData: TestDataType = [:]
        let testKey = "keyyyyFromReadsTest"
        let testValue = "hello"

        testData[testKey] = testValue

        for storageModule in storageModules {
            await checkLoadedState(
                storageModule: storageModule,
                isLoaded: false
            )

            switch storageModule.dataStorageMedium {
            case .memory:
                await storageModule.loadData()
            case .userDefaults:
                let (medium, key) = storageModule.persistentStorage!
                try await medium.write(name: key, value: testData)

                await checkLoadedState(
                    storageModule: storageModule,
                    isLoaded: false
                )

                let value = await storageModule.read(name: testKey)

                if value != testValue {
                    let description = storageModule.description
                    XCTFail("load data not correct for \(description)")
                }
            case .fileSystem:
                let (medium, _) = storageModule.persistentStorage!
                try await medium.write(name: testKey, value: testData)

                await checkLoadedState(
                    storageModule: storageModule,
                    isLoaded: false
                )

                let value = await storageModule.read(name: testKey)

                if value != testValue {
                    let description = storageModule.description
                    XCTFail("load data not correct for \(description)")
                }
            }

            await checkLoadedState(storageModule: storageModule, isLoaded: true)
        }
    }

    func testLoadsDataOnDemandDuringWrites() async throws {
        let testKey = "keyyyyFromWritesTest"
        let testValue = "hello"

        for storageModule in storageModules {
            await checkLoadedState(
                storageModule: storageModule,
                isLoaded: false
            )
            try await storageModule.write(name: testKey, value: testValue)
            await checkLoadedState(storageModule: storageModule, isLoaded: true)
        }
    }

    func testFetchCurrentData() async throws {
        let testKey = "fetchKey"
        let testValue = "hello2"

        for storageModule in storageModules {
            let current1 = await storageModule.currentData()
            XCTAssertEqual(current1, [:], storageModule.description)

            try await storageModule.write(name: testKey, value: testValue)

            let current2 = await storageModule.currentData()

            XCTAssertEqual(current2, [testKey: testValue])
        }
    }

    func testDeleteNonExistingKey() async throws {
        for storageModule in storageModules {
            await storageModule.delete(name: UUID().uuidString)
        }
    }

    func testDeleteExistingKey() async throws {
        let key = "keyToDelete"
        let value = "valueToDelete"

        for storageModule in storageModules {
            try await storageModule.write(name: key, value: value)

            await storageModule.delete(name: key)

            let readValue = await storageModule.read(name: key)
            XCTAssertNil(readValue)
        }
    }

    func testClearAllData() async throws {
        for storageModule in storageModules {
            try await storageModule.write(name: "clearKey1", value: "value")
            try await storageModule.write(name: "clearKey2", value: "value")

            await storageModule.clear()

            let current = await storageModule.currentData()
            XCTAssertTrue(current.isEmpty)
        }
    }

    // MARK: - Private

    // need a helper since you can't use await in autoclosures to check actor fields
    // inline in an assertion.
    private func checkLoadedState(
        storageModule: ParraStorageModule<String>,
        isLoaded: Bool
    ) async {
        let isLoadedCheck = storageModule.isLoaded
        let description = storageModule.description

        XCTAssertEqual(
            isLoadedCheck,
            isLoaded,
            "checkLoadedState failed for module: \(description)"
        )
    }
}
