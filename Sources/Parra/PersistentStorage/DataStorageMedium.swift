//
//  DataStorageMedium.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

enum DataStorageMedium {
    case memory
    case fileSystem(
        baseUrl: URL,
        folder: String = DataManager.Directory.storageDirectoryName,
        fileName: String,
        storeItemsSeparately: Bool = true,
        fileManager: FileManager
    )
    case fileSystemEncrypted(
        baseUrl: URL,
        folder: String,
        fileName: String,
        fileManager: FileManager
    )
    case userDefaults(key: String)
    case keychain(key: String)
}
