//
//  FileManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import Foundation
import UIKit

extension FileManager {
    func safeCreateDirectory(at url: URL) throws {
        print("Checking if directory exists at: \(url.path)")
        var isDirectory: ObjCBool = false
        let exists = fileExists(
            atPath: url.path,
            isDirectory: &isDirectory
        )
        
        if exists && !isDirectory.boolValue {
            print("Error: File existed at directory path.")
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
            print("Directory didn't exist. Creating...")
            try createDirectory(at: url, withIntermediateDirectories: true)
        } else {
            print("Directory already exists")
        }
    }
}
