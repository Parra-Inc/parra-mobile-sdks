//
//  CredentialStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

internal actor CredentialStorage: ItemStorage {
    internal enum Key {
        static let currentUser = "current_user_credential"
    }
    
    typealias DataType = ParraCredential
    
    let storageModule: ParraStorageModule<ParraCredential>
    
    init(storageModule: ParraStorageModule<ParraCredential>) {
        self.storageModule = storageModule
    }
    
    func updateCredential(credential: ParraCredential?) async {
        try? await storageModule.write(name: Key.currentUser, value: credential)
    }
    
    func currentCredential() async -> ParraCredential? {
        return await storageModule.read(name: Key.currentUser)
    }
}
