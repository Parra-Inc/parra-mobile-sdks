//
//  ParraDataManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

class ParraDataManager {
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

    func getCurrentCredential() async -> ParraCredential? {
        return await credentialStorage.currentCredential()
    }

    func updateCredential(credential: ParraCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
    }
}
