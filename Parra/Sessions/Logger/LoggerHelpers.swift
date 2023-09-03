//
//  LoggerHelpers.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import Darwin

internal typealias SplitFileId = (
    module: String,
    fileName: String,
    fileExtension: String?
)

internal struct LoggerHelpers {
    // TODO: Should be LRU and size limited, and thread safe before enabling
//    private static var fileIdCache = [String : SplitFileId]()

    /// Useful for converting various types of "Error" into an actual readable message. By default
    /// Error conforming types will not display what type of error they actually are in their
    /// localizedDescription, for example.
    internal static func extractMessageAndExtra(
        from error: Error
    ) -> ParraErrorWithExtra {
        if let parraError = error as? ParraError {
            return ParraErrorWithExtra(parraError: parraError)
        } else {
            return ParraErrorWithExtra(error: error)
        }
    }

    /// Safely splits a file id (#fileID) into a module name, a file name and a file extension.
    internal static func splitFileId(
        fileId: String
    ) -> SplitFileId {
//        if let cached = readFileIdFromCache(for: fileId) {
//            return cached
//        }

        let (module, fileName) = splitFileId(fileId: fileId)

        let fileParts = fileName.split(separator: ".")
        let components: SplitFileId
        if fileParts.count == 1 {
            // No file extension found
            components = (module, fileName, nil)
        } else {
            // Handles cases where file extensions have multiple periods.
            components = (module, String(fileParts[0]), fileParts.dropFirst(1).joined(separator: "."))
        }

//        writeFileIdToCache(fileId: fileId, components: components)

        return components
    }

    /// Safely splits a file id (#fileID) into a module name, and a file name, with extension.
    /// E.x. Demo/AppDelegate.swift (same if logger is top level)
    internal static func splitFileId(
        fileId: String
    ) -> (module: String, fileName: String) {
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

    /// Generates a slug representative of a callsite.
    internal static func createFormattedLocation(
        fileId: String,
        function: String,
        line: Int
    ) -> String {
        let file: String
        if let extIndex = fileId.lastIndex(of: ".") {
            file = String(fileId[..<extIndex])
        } else {
            file = fileId
        }

        let functionName: String
        if let parenIndex = function.firstIndex(of: "(") {
            functionName = String(function[..<parenIndex])
        } else {
            functionName = function
        }

        return "\(file).\(functionName)#\(line)"
    }

    // Not sure if we'll end up needing this. This may just always return the
    // same thing.
    internal static func getCurrentDynamicLibrary(
        _ dynamicObjectHandle: UnsafeRawPointer = #dsohandle
    ) -> String? {
        var info = Dl_info()

        guard dladdr(dynamicObjectHandle, &info) != 0 else {
            return nil
        }

        return String(cString: info.dli_fname)
    }

    // MARK: FileId Cache

//    private static func readFileIdFromCache(
//        for fileId: String
//    ) -> SplitFileId? {
//        return fileIdCache[fileId]
//    }
//
//    private static func writeFileIdToCache(
//        fileId: String,
//        components: SplitFileId
//    ) {
//        fileIdCache[fileId] = components
//    }
}
