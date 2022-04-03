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
    dynamic static func bundle() -> Bundle {
        return Bundle(for: self as! AnyClass)
    }
    
    dynamic static func libraryVersion() -> String {
        return bundle().infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static func persistentStorageFolder() -> String {
        return name.lowercased()
    }
}
