//
//  API+releases.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension API {
    func getRelease(
        with releaseId: String
    ) async throws -> ParraAppRelease {
        return try await hitEndpoint(
            .getRelease(
                releaseId: releaseId
            )
        )
    }

    func paginateReleases(
        limit: Int,
        offset: Int
    ) async throws -> AppReleaseCollectionResponse {
        return try await hitEndpoint(
            .getPaginateReleases,
            queryItems: [
                "limit": String(limit),
                "offset": String(offset)
            ]
        )
    }
}
