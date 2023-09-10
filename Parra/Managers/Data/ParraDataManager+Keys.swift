//
//  ParraDataManager+Keys.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// !!! Think really before changing anything here!
public extension ParraDataManager {
    enum Base {
        public static let applicationSupportDirectory = Parra.fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        public static let documentDirectory = Parra.fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        public static let cachesURL = Parra.fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        public static let homeUrl = URL(
            fileURLWithPath: NSHomeDirectory(),
            isDirectory: true
        )
    }

    internal enum Directory {
        static let storageDirectoryName = "storage"
    }

    internal enum Path {
        internal static let networkCachesDirectory = Base.cachesURL.safeAppendDirectory("ParraNetworkCache")

        internal static let parraDirectory = Base.applicationSupportDirectory.safeAppendDirectory("parra")

        internal static let storageDirectory = parraDirectory.safeAppendDirectory(
            Directory.storageDirectoryName
        )
    }

    internal enum Key {
        internal static let userCredentialsKey = "com.parra.usercredential"
        internal static let userSessionsKey = "com.parra.usersession"
    }
}
