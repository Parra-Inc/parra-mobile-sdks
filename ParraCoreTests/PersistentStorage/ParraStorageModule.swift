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
    var storageModules = [ParraStorageModule<TestDataType>]()
    
    override func setUpWithError() throws {
        let folder = "storage_modules"
        let file = "storage_data"
        
        storageModules = [
            .init(dataStorageMedium: .memory),
            .init(dataStorageMedium: .fileSystem(folder: folder, fileName: file)),
            .init(dataStorageMedium: .userDefaults(key: file)),
        ]
    }

    func _testLoadsDataWhenPresent() async throws {
        let data: [String: String] = [
            "key": "value"
        ]

        for storageModule in storageModules {
            switch await storageModule.dataStorageMedium {
            case .memory:
                break
            case .userDefaults:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()
                
                let readData = await storageModule.read(name: key)
                XCTAssertEqual(data, readData)
            case .fileSystem:
                let (medium, key) = await storageModule.persistentStorage!
                try await medium.write(name: key, value: data)
                await storageModule.loadData()
                
                let readData = await storageModule.read(name: key)
                XCTAssertEqual(data, readData)
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
    
    func testLoadsDataOnDemand() throws {
    }
}
