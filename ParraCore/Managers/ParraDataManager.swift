//
//  ParraDataManager.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public class ParraDataManager {
    internal fileprivate(set) var credentialStorage: CredentialStorage
    internal fileprivate(set) var sessionStorage: SessionStorage

    internal init() {
        let folder = Parra.persistentStorageFolder()
        
        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                folder: folder,
                fileName: ParraDataManager.Key.userCredentialsKey
            )
        )

        let sessionStorageModule = ParraStorageModule<ParraSession>(
            dataStorageMedium: .fileSystem(
                folder: folder,
                fileName: ParraDataManager.Key.userSessionsKey
            )
        )
        
        self.credentialStorage = CredentialStorage(storageModule: credentialStorageModule)
        self.sessionStorage = SessionStorage(storageModule: sessionStorageModule)
    }
    
    internal func getCurrentCredential() async -> ParraCredential? {
        return await credentialStorage.currentCredential()
    }
    
    internal func updateCredential(credential: ParraCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
    }
}

internal class MockDataManager: ParraDataManager {
    override init() {
        super.init()
        
        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .memory
        )
        
        self.credentialStorage = CredentialStorage(storageModule: credentialStorageModule)
    }
}
