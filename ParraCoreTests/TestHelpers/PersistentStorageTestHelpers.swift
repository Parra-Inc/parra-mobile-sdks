//
//  FileSystemHelpers.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
import ParraCore

let applicationSupportDirectory = FileManager.default.urls(
    for: .applicationSupportDirectory,
       in: .userDomainMask
).first!

func deleteDirectoriesInApplicationSupport() throws {
    let directoryPaths = try FileManager.default.contentsOfDirectory(
        at: applicationSupportDirectory,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: .skipsHiddenFiles
    )

    for directoryPath in directoryPaths {
        try FileManager.default.removeItem(at: directoryPath)
    }
}

func clearParraUserDefaultsSuite() {
    if let bundleIdentifier = Parra.bundle().bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(
            forName: bundleIdentifier
        )
        UserDefaults.standard.synchronize()
    }
}
