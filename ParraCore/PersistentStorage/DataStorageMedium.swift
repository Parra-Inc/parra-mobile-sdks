//
//  DataStorageMedium.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public enum DataStorageMedium {
    case memory
    case fileSystem(folder: String, fileName: String, storeItemsSeparately: Bool)
    case userDefaults(key: String)
}
