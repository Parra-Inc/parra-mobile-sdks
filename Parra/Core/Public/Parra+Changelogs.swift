//
//  Parra+Changelogs.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
    func fetchLatestRelease() async throws -> NewInstalledVersionInfo? {
        let versionManager = LatestVersionManager(
            networkManager: parraInternal.networkManager
        )

        let latestVersionToken = await versionManager.latestVersionToken()

        let response = try await parraInternal.networkManager.getAppInfo(
            versionToken: latestVersionToken
        )

        await versionManager.updateLatestSeenVersionToken(response.versionToken)

        return response.newInstalledVersionInfo
    }
}
