//
//  FileManager.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

internal extension FileManager {
    func safeCreateDirectory(at url: URL) throws {
        let logName = url.pathComponents.suffix(3).joined(separator: "/")
        
        parraLogD("Checking if directory exists at: \(logName)")
        var isDirectory: ObjCBool = false
        let exists = fileExists(
            atPath: url.path,
            isDirectory: &isDirectory
        )
        
        if exists && !isDirectory.boolValue {
            parraLogD("Error: File existed at directory path \(logName)")
            throw NSError(
                domain: "Parra",
                code: 2139,
                userInfo: [
                    NSLocalizedDescriptionKey: "Tried to create a directory at a location that already contained a file.",
                    NSLocalizedFailureReasonErrorKey: "File existed at path: \(url.path)"
                ]
            )
        }
        
        if !exists {
            parraLogD("Directory didn't exist at \(logName). Creating...")
            try createDirectory(at: url, withIntermediateDirectories: true)
        } else {
            parraLogD("Directory already exists at \(url)")
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
