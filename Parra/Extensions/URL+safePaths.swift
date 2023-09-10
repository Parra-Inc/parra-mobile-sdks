//
//  URL+safePaths.swift
//  Parra
//
//  Created by Mick MacCallum on 12/30/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal extension URL {
    func safeAppendDirectory(_ dir: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(path: dir, directoryHint: .isDirectory)
        } else {
            return appendingPathComponent(dir, isDirectory: true)
        }
    }

    func safeAppendPathComponent(_ pathComponent: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(component: pathComponent, directoryHint: .notDirectory)
        } else {
            return appendingPathComponent(pathComponent, isDirectory: false)
        }
    }

    func safeNonEncodedPath() -> String {
        if #available(iOS 16.0, *) {
            return path(percentEncoded: false)
        } else {
            return path
        }
    }

    static func safeUrlFromPath(
        path: String,
        relativeTo base: URL
    ) -> URL {
        if #available(iOS 16.0, *) {
            return URL(
                filePath: path,
                directoryHint: .inferFromPath,
                relativeTo: base
            )
        }

        return URL(
            fileURLWithPath: path,
            relativeTo: base
        )
    }

    func privateRelativePath() -> String {
        guard isFileURL else {
            return absoluteString
        }

        let prefix = ParraDataManager.Base.homeUrl.absoluteString
        let base = absoluteString

        if #available(iOS 16.0, *) {
            return String(base.trimmingPrefix(prefix))
        } else {
            if base.hasPrefix(prefix) {
                return String(base.dropFirst(prefix.count))
            } else {
                return lastComponents()
            }
        }
    }
}
