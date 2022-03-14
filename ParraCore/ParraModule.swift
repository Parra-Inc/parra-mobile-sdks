//
//  ParraModule.swift
//  Parra Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

public protocol ParraModule {
    static var name: String { get }
    
    func hasDataToSync() async -> Bool
    func triggerSync() async -> Void
}

public extension ParraModule {
    static func bundle() -> Bundle {
        return Bundle(for: self as! AnyClass)
    }
    
    static func persistentStorageFolder() -> String {
        return name.lowercased()
    }
    
    static func persistentStorageDirectory() -> URL {
        return ParraDataManager.Path.parraDirectory.appendingPathComponent(
            persistentStorageFolder(),
            isDirectory: true
        )
    }
}
