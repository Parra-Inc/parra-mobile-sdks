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

    func getAccessToken() async -> String? {
        return await getCurrentCredential()?.accessToken
    }

    func getCurrentCredential() async -> ParraUser.Credential? {
        return await credentialStorage.currentUser()?.credential
    }

    func updateCurrentUser(_ user: ParraUser?) async {
        if let user {
            await credentialStorage.updateCredential(
                credential: user
            )
        } else {
            await removeCurrentUser()
        }
    }

    func updateCurrentUserCredential(
        _ credential: ParraUser.Credential
    ) async {
        if let user = await getCurrentUser() {
            let newUser = ParraUser(
                credential: credential,
                info: user.info
            )

            await updateCurrentUser(newUser)
        }
    }

    func removeCurrentUser() async {
        if await getCurrentUser() != nil {
            await credentialStorage.updateCredential(
                credential: nil
            )
        }
    }
}
