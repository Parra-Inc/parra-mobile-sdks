//
//  ParraDataManager+Keys.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// !!! Think really before changing anything here!
internal extension ParraDataManager {
    enum Base {
        internal static let applicationSupportDirectory = Parra.fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        internal static let documentDirectory = Parra.fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        internal static let cachesURL = Parra.fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        internal static let homeUrl = URL(
            fileURLWithPath: NSHomeDirectory(),
            isDirectory: true
        )
    }

    enum Directory {
        static let storageDirectoryName = "storage"
    }

    enum Path {
        internal static let networkCachesDirectory = Base.cachesURL.safeAppendDirectory("ParraNetworkCache")

        internal static let parraDirectory = Base.applicationSupportDirectory.safeAppendDirectory("parra")

        internal static let storageDirectory = parraDirectory.safeAppendDirectory(
            Directory.storageDirectoryName
        )
    }

    enum Key {
        internal static let userCredentialsKey = "com.parra.usercredential"
        internal static let userSessionsKey = "com.parra.usersession"
    }
}
