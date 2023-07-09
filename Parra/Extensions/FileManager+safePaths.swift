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
        let logName = url.pathComponents.suffix(3).joined(separator: "/")
        
        logger.trace("Checking if directory exists at: \(logName)")
        var isDirectory: ObjCBool = false
        let exists = fileExists(
            atPath: url.path,
            isDirectory: &isDirectory
        )
        
        if exists && !isDirectory.boolValue {
            let error = NSError(
                domain: "Parra",
                code: 2139,
                userInfo: [
                    NSLocalizedDescriptionKey: "Tried to create a directory at a location that already contained a file.",
                    NSLocalizedFailureReasonErrorKey: "File existed at path: \(url.path)"
                ]
            )

            logger.error("Error: File existed at directory path \(logName)", error)

            throw error
        }
        
        if !exists {
            logger.trace("Directory didn't exist at \(logName). Creating...")
            try createDirectory(at: url, withIntermediateDirectories: true)
        } else {
            logger.trace("Directory already exists at \(logName)")
        }
    }

    func safeFileExists(at url: URL) -> Bool {
        if #available(iOS 16.0, *) {
            return fileExists(atPath: url.path(percentEncoded: false))
        } else {
            return fileExists(atPath: url.path)
        }
    }
}
