//
//  DataManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

class DataManager {
    // MARK: - Lifecycle

    init(
        baseDirectory: URL,
        credentialStorage: CredentialStorage,
        sessionStorage: SessionStorage
    ) {
        self.baseDirectory = baseDirectory
        self.credentialStorage = credentialStorage
        self.sessionStorage = sessionStorage
    }

    // MARK: - Internal

    let baseDirectory: URL
    let credentialStorage: CredentialStorage
    let sessionStorage: SessionStorage

    func getCurrentUser() async -> ParraUser? {
        return await credentialStorage.currentUser()
    }

    func updateCredential(credential: ParraUser?) async {
        await credentialStorage.updateCredential(
            credential: credential
        )
    }
}
