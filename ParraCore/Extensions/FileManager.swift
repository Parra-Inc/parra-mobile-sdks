//
//  FileManager.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation

extension FileManager {
    func safeCreateDirectory(at url: URL) throws {
        parraLogV("Checking if directory exists at: \(url.path)")
        var isDirectory: ObjCBool = false
        let exists = fileExists(
            atPath: url.path,
            isDirectory: &isDirectory
        )
        
        if exists && !isDirectory.boolValue {
            parraLogV("Error: File existed at directory path.")
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
            parraLogV("Directory didn't exist. Creating...")
            try createDirectory(at: url, withIntermediateDirectories: true)
        } else {
            parraLogV("Directory already exists")
        }
    }
}
