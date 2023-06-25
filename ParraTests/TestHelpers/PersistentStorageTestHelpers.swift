//
//  FileSystemHelpers.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
@testable import Parra

func deleteDirectoriesInApplicationSupport() throws {
    let directoryPaths = try FileManager.default.contentsOfDirectory(
        at: ParraDataManager.Base.applicationSupportDirectory,
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
