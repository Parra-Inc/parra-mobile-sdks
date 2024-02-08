//
//  ParraDataManager+Keys.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// !!! Think really before changing anything here!
extension ParraDataManager {
    enum Base {
        static let applicationSupportDirectory = Parra.fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        static let documentDirectory = Parra.fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        static let cachesURL = Parra.fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        static let homeUrl = URL(
            fileURLWithPath: NSHomeDirectory(),
            isDirectory: true
        )
    }

    enum Directory {
        static let storageDirectoryName = "storage"
    }

    enum Path {
        static let networkCachesDirectory = Base.cachesURL
            .appendDirectory("parra-network-cache")

        static let parraDirectory = Base.applicationSupportDirectory
            .appendDirectory("parra")
    }

    enum Key {
        static let userCredentialsKey = "com.parra.usercredential"
        static let userSessionsKey = "com.parra.usersession"
    }
}
