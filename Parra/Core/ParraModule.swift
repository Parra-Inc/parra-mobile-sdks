//
//  ParraModule.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

internal protocol ParraModule: Syncable {
    static var name: String { get }

    func didReceiveSessionResponse(sessionResponse: ParraSessionsResponse)
}

internal extension ParraModule {
    dynamic static func bundle() -> Bundle {
        if let `class` = self as? AnyClass {
            return Bundle(for: `class`)
        }

        return .main
    }
    
    dynamic static func errorDomain() -> String {
        return "com.parra.error"
    }
    
    dynamic static func libraryVersion() -> String {
        return bundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    static func eventPrefix() -> String {
        return "parra:\(name.lowercased())"
    }

    func didReceiveSessionResponse(sessionResponse: ParraSessionsResponse) {}
}
