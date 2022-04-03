//
//  ParraDataManager.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public class ParraDataManager {
    internal fileprivate(set) var credentialStorage: CredentialStorage
        
    init() {
        let folder = Parra.persistentStorageFolder()
        let fileName = ParraDataManager.Key.userCredentialsKey
        
        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                folder: folder,
                fileName: fileName
            )
        )
        
        self.credentialStorage = CredentialStorage(storageModule: credentialStorageModule)
    }
    
    func getCurrentCredential() async -> ParraCredential? {
        return await credentialStorage.currentCredential()
    }
    
    func updateCredential(credential: ParraCredential?) async {
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
