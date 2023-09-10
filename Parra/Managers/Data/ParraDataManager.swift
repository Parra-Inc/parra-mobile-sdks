//
//  ParraDataManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public class ParraDataManager {
    internal fileprivate(set) var credentialStorage: CredentialStorage
    internal fileprivate(set) var sessionStorage: SessionStorage

    internal init(
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) {
        let folder = ParraDataManager.Directory.storageDirectoryName

        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                folder: folder,
                fileName: ParraDataManager.Key.userCredentialsKey,
                storeItemsSeparately: false,
                fileManager: fileManager
            ),
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )

        let sessionStoragePath = ParraDataManager.Path.parraDirectory
            .safeAppendDirectory(folder.appending("/sessions"))

        self.credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        self.sessionStorage = SessionStorage(
            sessionReader: SessionReader(
                basePath: sessionStoragePath,
                jsonDecoder: jsonDecoder,
                fileManager: fileManager
            ),
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
    }
    
    internal func getCurrentCredential() async -> ParraCredential? {
        return await credentialStorage.currentCredential()
    }
    
    internal func updateCredential(credential: ParraCredential?) async {
        await credentialStorage.updateCredential(credential: credential)
    }
}

internal class MockDataManager: ParraDataManager {
    override init(
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) {
        super.init(
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            fileManager: fileManager
        )

        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .memory,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
        
        self.credentialStorage = CredentialStorage(storageModule: credentialStorageModule)
    }
}
