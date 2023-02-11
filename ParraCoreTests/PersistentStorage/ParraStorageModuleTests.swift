//
//  ParraStorageModule.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import XCTest
@testable import ParraCore

typealias TestDataType = [String: String]

class ParraStorageModuleTests: XCTestCase {
    var storageModules = [ParraStorageModule<String>]()
    
    override func setUpWithError() throws {        
        try deleteDirectoriesInApplicationSupport()
        clearParraUserDefaultsSuite()
        
        let folder = "storage_modules"
        let file = "storage_data"
        
        storageModules = [
            .init(dataStorageMedium: .memory),
            .init(dataStorageMedium: .fileSystem(folder: folder, fileName: file, storeItemsSeparately: true)),
            .init(dataStorageMedium: .userDefaults(key: file)),
        ]
    }
    
    override func tearDownWithError() throws {
        try deleteDirectoriesInApplicationSupport()
        clearParraUserDefaultsSuite()
    }

    func testLoadsDataWhenPresent() async throws {
        var data: TestDataType = [:]
        let testKey = "keyyyyFromLoadsData"
        let testValue = "hello"
        
        data[testKey] = testValue

        for storageModule in storageModules {
            switch await storageModule.dataStorageMedium {
            case .memory:
                break
            case .userDefaults:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()

                let cache = await storageModule.storageCache
                XCTAssertEqual(data, cache)

                let readData = await storageModule.read(name: testKey)
                XCTAssertEqual(readData, testValue)
            case .fileSystem:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()

                let cache = await storageModule.storageCache
                XCTAssertEqual([:], cache)
            }
        }
    }
    
    func testLoadsDataWhenNotPresent() async throws {
        for storageModule in storageModules {
            await storageModule.loadData()
            
            let isLoaded = await storageModule.isLoaded
            let medium = await storageModule.dataStorageMedium
            XCTAssertTrue(isLoaded, "isLoaded failed for \(medium)")
        }
    }
    
    func testLoadsDataOnDemandDuringReads() async throws {
        var testData: TestDataType = [:]
        let testKey = "keyyyyFromReadsTest"
        let testValue = "hello"
        
        testData[testKey] = testValue

        for storageModule in storageModules {
            await checkLoadedState(storageModule: storageModule, isLoaded: false)

            switch await storageModule.dataStorageMedium {
            case .memory:
                await storageModule.loadData()
            case .userDefaults:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: testData)

                await checkLoadedState(storageModule: storageModule, isLoaded: false)

                let value = await storageModule.read(name: testKey)

                if value != testValue {
                    let description = await storageModule.description
                    XCTFail("load data not correct for \(description)")
                }
            case .fileSystem:
                let (medium, _) = await storageModule.persistentStorage!
                try await medium.write(name: testKey, value: testData)

                await checkLoadedState(storageModule: storageModule, isLoaded: false)
                
                let value = await storageModule.read(name: testKey)

                if value != testValue {
                    let description = await storageModule.description
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
            await checkLoadedState(storageModule: storageModule, isLoaded: false)
            try await storageModule.write(name: testKey, value: testValue)
            await checkLoadedState(storageModule: storageModule, isLoaded: true)
        }
    }
    
    func testFetchCurrentData() async throws {
        let testKey = "fetchKey"
        let testValue = "hello2"

        for storageModule in storageModules {
            let current1 = await storageModule.currentData()
            let d = await storageModule.description
            XCTAssertEqual(current1, [:], d)
            
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
    
    // need a helper since you can't use await in autoclosures to check actor fields
    // inline in an assertion.
    private func checkLoadedState(storageModule: ParraStorageModule<String>, isLoaded: Bool) async {
        let isLoadedCheck = await storageModule.isLoaded
        let description = await storageModule.description
        
        XCTAssertEqual(isLoadedCheck, isLoaded, "checkLoadedState failed for module: \(description)")
    }
}
