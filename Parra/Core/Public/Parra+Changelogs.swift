//
//  Parra+Changelogs.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    /// Fetches information about the most recent release of your app from
    /// Parra. This information can be used to render custom UI, or with Parra's
    /// ``presentParraRelease`` View modifier to present a sheet showing off the
    /// details of the release.
    func fetchLatestRelease() async throws -> AppInfo {
        return try await parraInternal.latestVersionManager.fetchLatestAppInfo()
    }
}
