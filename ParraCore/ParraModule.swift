//
//  ParraModule.swift
//  Parra Core
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

public protocol ParraModule: Syncable {
    static var name: String { get }
}

public extension ParraModule {
    dynamic static func bundle() -> Bundle {
        if let `class` = self as? AnyClass {
            return Bundle(for: `class`)
        }

        return .main
    }
    
    dynamic static func errorDomain() -> String {
        return "com.parra.\(name.lowercased()).error"
    }
    
    dynamic static func libraryVersion() -> String {
        return bundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    static func persistentStorageFolder() -> String {
        return name.lowercased()
    }

    static func eventPrefix() -> String {
        return "parra:\(name.lowercased())"
    }
}
