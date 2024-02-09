//
//  CredentialStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

private let logger = Logger(category: "Credential storage")

actor CredentialStorage: ItemStorage {
    // MARK: - Lifecycle

    init(storageModule: ParraStorageModule<ParraCredential>) {
        self.storageModule = storageModule
    }

    // MARK: - Internal

    enum Key {
        static let currentUser = "current_user_credential"
    }

    typealias DataType = ParraCredential

    let storageModule: ParraStorageModule<ParraCredential>

    func updateCredential(credential: ParraCredential?) async {
        do {
            try await storageModule.write(
                name: Key.currentUser,
                value: credential
            )
        } catch {
            logger.error("error updating credential", error)
        }
    }

    func currentCredential() async -> ParraCredential? {
        return await storageModule.read(name: Key.currentUser)
    }
}
