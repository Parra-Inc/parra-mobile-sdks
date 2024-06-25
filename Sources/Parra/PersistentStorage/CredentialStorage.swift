//
//  CredentialStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

private let logger = Logger(category: "Credential storage")

final class CredentialStorage: ItemStorage {
    // MARK: - Lifecycle

    required init(storageModule: ParraStorageModule<ParraUser>) {
        self.storageModule = storageModule
    }

    // MARK: - Internal

    let storageModule: ParraStorageModule<ParraUser>

    func updateCredential(credential: ParraUser?) async {
        do {
            try await storageModule.write(
                name: DataManager.Key.userCredentialsKey,
                value: credential
            )
        } catch {
            logger.error("error updating credential", error)
        }
    }

    func currentUser() async -> ParraUser? {
        return await storageModule.read(
            name: DataManager.Key.userCredentialsKey,
            deleteOnError: true
        )
    }
}
