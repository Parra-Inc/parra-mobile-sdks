//
//  FileSystemHelpers.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
@testable import Parra

func deleteDirectoriesInApplicationSupport() throws {
    let fileManager = FileManager.default
    let baseDirectory = ParraDataManager.Base.applicationSupportDirectory

    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(
        atPath: baseDirectory.safeNonEncodedPath(),
        isDirectory: &isDirectory
    )

    if !exists || !isDirectory.boolValue {
        return
    }

    let directoryPaths = try fileManager.contentsOfDirectory(
        at: baseDirectory,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: .skipsHiddenFiles
    )

    for directoryPath in directoryPaths {
        try fileManager.removeItem(at: directoryPath)
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
