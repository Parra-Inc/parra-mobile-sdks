//
//  CredentialStorageTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import ParraCore

class CredentialStorageTests: XCTestCase {
    var storageModule: ParraStorageModule<ParraCredential>!
    var credentialStorage: CredentialStorage!
    
    override func setUpWithError() throws {
        storageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .memory
        )
        
        credentialStorage = CredentialStorage(
            storageModule: storageModule
        )
    }

    override func tearDownWithError() throws {
        credentialStorage = nil
        storageModule = nil
    }

    func testCanUpdateCredential() async throws {
        let credential = ParraCredential(
            token: UUID().uuidString
        )
        
        await credentialStorage.updateCredential(credential: credential)
        
        let value = await storageModule.read(name: CredentialStorage.Key.currentUser)
        
        XCTAssertEqual(value, credential)
    }
    
    func testCanRetreiveCurrentCredential() async throws {
        let credential = ParraCredential(
            token: UUID().uuidString
        )
        
        await credentialStorage.updateCredential(credential: credential)
        
        let value = await credentialStorage.currentCredential()
        
        XCTAssertEqual(value, credential)
    }
}
