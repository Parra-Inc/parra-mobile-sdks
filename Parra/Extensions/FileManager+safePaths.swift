//
//  FileManager+safePaths.swift
//  Parra
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

fileprivate let logger = Logger(category: "Extensions")

internal extension FileManager {
    func safeCreateDirectory(at url: URL) throws {
        try logger.withScope { logger in
            let logName = url.lastComponents()
            logger.trace("Checking if directory exists at: \(logName)")

            let (exists, isDirectory) = safeFileExists(at: url)

            if exists && !isDirectory {
                throw ParraError.fileSystem(
                    path: url,
                    message: "Attempted to create a directory at a path that already contained a file."
                )
            }

            if !exists {
                logger.trace("Directory didn't exist at \(logName). Creating...")
                try createDirectory(at: url, withIntermediateDirectories: true)
            } else {
                logger.trace("Directory already exists at \(logName)")
            }
        }
    }

    func safeCreateFile(
        at url: URL,
        contents: Data? = nil,
        attributes: [FileAttributeKey : Any]? = nil
    ) throws {
        try logger.withScope { logger in
            let logName = url.lastComponents()
            logger.trace("Checking if file exists at: \(logName)")

            let exists: Bool = try safeFileExists(at: url)

            if exists {
                throw ParraError.fileSystem(
                    path: url,
                    message: "File already exists."
                )
            }

            let success = createFile(
                atPath: url.safeNonEncodedPath(),
                contents: contents,
                attributes: attributes
            )

            if !success {
                throw ParraError.fileSystem(
                    path: url,
                    message: "File could not be created"
                )
            }
        }
    }

    func safeFileExists(at url: URL) -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false

        let exists = fileExists(
            atPath: url.safeNonEncodedPath(),
            isDirectory: &isDirectory
        )

        return (
            exists: exists,
            isDirectory: isDirectory.boolValue
        )
    }


    func safeFileExists(at url: URL) throws -> Bool {
        let (exists, isDirectory) = safeFileExists(at: url)

        if isDirectory {
            throw ParraError.fileSystem(
                path: url,
                message: "Directory exists at location where file should be created."
            )
        }

        return exists
    }
}
