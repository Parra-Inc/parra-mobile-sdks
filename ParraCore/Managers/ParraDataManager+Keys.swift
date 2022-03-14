//
//  ParraDataManager+Keys.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

private let applicationSupportDirectory = FileManager.default.urls(
    for: .applicationSupportDirectory,
       in: .userDomainMask
).first!

// !!! Think really before changing anything here!
public extension ParraDataManager {
    enum Path {
        public static let parraDirectory = applicationSupportDirectory.appendingPathComponent("parra",
                                                                                       isDirectory: true)
    }
    
    enum Key {
        static let userCredentialsKey = "com.parra.usercredential"
    }    
}
