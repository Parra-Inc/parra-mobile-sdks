//
//  DataStorageMedium.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

internal enum DataStorageMedium {
    case memory
    case fileSystem(
        folder: String,
        fileName: String,
        storeItemsSeparately: Bool,
        fileManager: FileManager
    )
    case userDefaults(key: String)
}
