//
//  DataManager+Keys.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

// !!! Think really before changing anything here!
extension DataManager {
    enum Base {
        static let applicationSupportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        static let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        static let cachesURL = FileManager.default.urls(
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
