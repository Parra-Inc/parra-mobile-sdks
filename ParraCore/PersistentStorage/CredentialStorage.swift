//
//  CredentialStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

private let kCurrentUserKey = "current_user_credential"

actor CredentialStorage: ItemStorage {
    typealias DataType = ParraCredential
    
    let storageModule: ParraStorageModule<ParraCredential>

    init(storageModule: ParraStorageModule<ParraCredential>) {
        self.storageModule = storageModule
    }

    func updateCredential(credential: ParraCredential?) {
        Task {
            try await storageModule.write(name: kCurrentUserKey, value: credential)
        }
    }
    
    func currentCredential() async -> ParraCredential? {
        return await storageModule.read(name: kCurrentUserKey)
    }
}
