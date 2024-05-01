//
//  API+releases.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func getAppInfo(
        versionToken: String?
    ) async throws -> AppInfo {
        var queryItems = [String: String]()

        if let versionToken {
            // If nil, key not be set.
            queryItems["version_token"] = versionToken
        }

        return try await hitEndpoint(
            .getAppInfo(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            ),
            queryItems: queryItems
        )
    }

    func getRelease(
        with releaseId: String
    ) async throws -> AppRelease {
        return try await hitEndpoint(
            .getRelease(
                releaseId: releaseId,
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            )
        )
    }

    func paginateReleases(
        limit: Int,
        offset: Int
    ) async throws -> AppReleaseCollectionResponse {
        return try await hitEndpoint(
            .getPaginateReleases(
                tenantId: appState.tenantId,
                applicationId: appState.applicationId
            ),
            queryItems: [
                "limit": String(limit),
                "offset": String(offset)
            ]
        )
    }
}
