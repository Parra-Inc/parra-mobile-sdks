//
//  ParraDataManager+Keys.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// !!! Think really before changing anything here!
public extension ParraDataManager {
    enum Base {
        public static let applicationSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        public static let cachesURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!
    }

    enum Path {
        internal static let networkCachesDirectory = Base.cachesURL.safeAppendDirectory("ParraNetworkCache")
        public static let parraDirectory = Base.applicationSupportDirectory.safeAppendDirectory("parra")
    }
    
    enum Key {
        internal static let userCredentialsKey = "com.parra.usercredential"
        internal static let userSessionsKey = "com.parra.usersession"
    }
}
