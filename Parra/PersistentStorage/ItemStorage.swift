//
//  ItemStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

internal protocol ItemStorage {
    associatedtype DataType: Codable
    
    init(storageModule: ParraStorageModule<DataType>)
}
