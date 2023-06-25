//
//  LoggerHelpers.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct LoggerHelpers {
    /// Useful for converting various types of "Error" into an actual readable message. By default
    /// Error conforming types will not display what type of error they actually are in their
    /// localizedDescription, for example.
    internal static func extractMessage(
        from error: Error
    ) -> String {
        if let parraError = error as? ParraError {
            return parraError.errorDescription
        } else {
            // Error is always bridged to NSError, can't downcast to check.
            if type(of: error) is NSError.Type {
                let nsError = error as NSError

                return "Error domain: \(nsError.domain), code: \(nsError.code), description: \(nsError.localizedDescription)"
            } else {
                return "\(String(reflecting: error)), description: \(error.localizedDescription)"
            }
        }
    }

    /// Safely splits a file id (#fileID) into a module name, a file name and a file extension.
    internal static func splitFileId(
        fileId: String
    ) -> (module: String, fileName: String, fileExtension: String) {
        let initialSplit = {
            let parts = fileId.split(separator: "/")

            if parts.count == 0 {
                return ("Unknown", "Unknown")
            } else if parts.count == 1 {
                return ("Unknown", String(parts[0]))
            } else if parts.count == 2 {
                return (String(parts[0]), String(parts[1]))
            } else {
                return (String(parts[0]), parts.dropFirst(1).joined(separator: "/"))
            }
        }

        let (module, fileName) = initialSplit()

        let fileParts = fileName.split(separator: ".")
        if fileParts.count == 1 {
            // No file extension found
            return (module, fileName, "")
        } else {
            return (module, String(fileParts[0]), fileParts.dropFirst(1).joined(separator: "."))
        }
    }

    /// Generates a slug representative of a callsite.
    internal static func createFormattedLocation(
        fileID: String,
        function: String,
        line: Int
    ) -> String {
        let file: String
        if let extIndex = fileID.lastIndex(of: ".") {
            file = String(fileID[..<extIndex])
        } else {
            file = fileID
        }

        let functionName: String
        if let parenIndex = function.firstIndex(of: "(") {
            functionName = String(function[..<parenIndex])
        } else {
            functionName = function
        }

        return "\(file).\(functionName)#\(line)"
    }
}
