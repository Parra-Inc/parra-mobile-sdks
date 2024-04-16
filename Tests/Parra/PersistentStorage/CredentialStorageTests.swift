//
//  CredentialStorageTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

class CredentialStorageTests: XCTestCase {
    var storageModule: ParraStorageModule<ParraUser.Credential>!
    var credentialStorage: CredentialStorage!

    override func setUpWithError() throws {
        storageModule = ParraStorageModule<ParraUser.Credential>(
            dataStorageMedium: .memory,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
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
        let credential = ParraUser.Credential(
            token: UUID().uuidString
        )

        await credentialStorage.updateCredential(credential: credential)

        let value = await storageModule
            .read(name: CredentialStorage.Key.currentUser)

        XCTAssertEqual(value, credential)
    }

    func testCanRetreiveCurrentCredential() async throws {
        let credential = ParraUser.Credential(
            token: UUID().uuidString
        )

        await credentialStorage.updateCredential(credential: credential)

        let value = await credentialStorage.currentCredential()

        XCTAssertEqual(value, credential)
    }
}
