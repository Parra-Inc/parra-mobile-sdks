//
//  CredentialStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

fileprivate let logger = Logger(category: "Credential storage")

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
        do {
            try await storageModule.write(name: Key.currentUser, value: credential)
        } catch let error {
            logger.error("error updating credential", error)
        }
    }
    
    func currentCredential() async -> ParraCredential? {
        return await storageModule.read(name: Key.currentUser)
    }
}
