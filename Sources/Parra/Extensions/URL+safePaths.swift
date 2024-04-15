//
//  URL+safePaths.swift
//  Parra
//
//  Created by Mick MacCallum on 12/30/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension URL {
    func appendDirectory(_ directory: String) -> URL {
        return appending(
            component: directory,
            directoryHint: .isDirectory
        )
    }

    func appendFilename(_ fileName: String) -> URL {
        return appending(
            component: fileName,
            directoryHint: .notDirectory
        )
    }

    func nonEncodedPath() -> String {
        return path(percentEncoded: false)
    }

    /// Should be used anywhere that a file paths from the target device may be stored and/or uploaded.
    /// This is a sanitization technique to prevent data like usernames or other sensitive information that might
    /// be in an absolute path from being stored.
    func privateRelativePath() -> String {
        guard isFileURL else {
            return absoluteString
        }

        let prefix = DataManager.Base.homeUrl.nonEncodedPath()
        let base = nonEncodedPath()
        let path = String(base.trimmingPrefix(prefix))

        return "~/\(path)"
    }
}
