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

        let folder = "storage_modules"
        let file = "storage_data"
        
        storageModules = [
            .init(dataStorageMedium: .memory),
            .init(dataStorageMedium: .fileSystem(folder: folder, fileName: file)),
            .init(dataStorageMedium: .userDefaults(key: file)),
        ]
    }
    
    override func tearDownWithError() throws {
        try deleteDirectoriesInApplicationSupport()
    }

    func testLoadsDataWhenPresent() async throws {
        var data: TestDataType = [:]
        let testKey = "keyyyy"
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
                XCTAssertEqual(data, cache)

                let readData = await storageModule.read(name: testKey)
                XCTAssertEqual(readData, testValue)
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
        let testKey = "keyyyy"
        let testValue = "hello"
        
        testData[testKey] = testValue

        for storageModule in storageModules {
            await checkLoadedState(storageModule: storageModule, isLoaded: false)

            switch await storageModule.dataStorageMedium {
            case .memory:
                await storageModule.loadData()
                break
            case .fileSystem, .userDefaults:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: testData)

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
        let testKey = "keyyyy"
        let testValue = "hello"

        for storageModule in storageModules {
            await checkLoadedState(storageModule: storageModule, isLoaded: false)
            try await storageModule.write(name: testKey, value: testValue)
            await checkLoadedState(storageModule: storageModule, isLoaded: true)
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
