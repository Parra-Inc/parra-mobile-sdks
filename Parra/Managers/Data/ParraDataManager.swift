//
//  ParraDataManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

internal class ParraDataManager {
    internal let baseDirectory: URL
    internal let credentialStorage: CredentialStorage
    internal let sessionStorage: SessionStorage

    internal init(
        baseDirectory: URL,
        credentialStorage: CredentialStorage,
        sessionStorage: SessionStorage
    ) {
        self.baseDirectory = baseDirectory
        self.credentialStorage = credentialStorage
        self.sessionStorage = sessionStorage
    }

    internal func getCurrentCredential() async -> ParraCredential? {
        return await credentialStorage.currentCredential()
    }
    
    internal func updateCredential(credential: ParraCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
    }
}
