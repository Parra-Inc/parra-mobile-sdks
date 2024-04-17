//
//  CredentialStorageTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

class CredentialStorageTests: XCTestCase {
    var storageModule: ParraStorageModule<ParraUser>!
    var credentialStorage: CredentialStorage!

    override func setUpWithError() throws {
        storageModule = ParraStorageModule<ParraUser>(
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
        let user = ParraUser(
            credential: ParraUser.Credential.basic(UUID().uuidString),
            info: ParraUser.Info()
        )

        await credentialStorage.updateCredential(credential: user)

        let value = await storageModule
            .read(name: CredentialStorage.Key.currentUser)

        XCTAssertEqual(value, user)
    }

    func testCanRetreiveCurrentCredential() async throws {
        let user = ParraUser(
            credential: ParraUser.Credential.basic(UUID().uuidString),
            info: ParraUser.Info()
        )

        await credentialStorage.updateCredential(credential: user)

        let value = await credentialStorage.currentUser()

        XCTAssertEqual(value, user)
    }
}
