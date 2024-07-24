//
//  AppRelease+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// MARK: - AppRelease + ParraFixture

extension AppRelease: ParraFixture {
    static func validStates() -> [AppRelease] {
        return AppReleaseStub.validStates().enumerated().map { _, element in
            return AppRelease(
                id: element.id,
                createdAt: element.createdAt,
                updatedAt: element.updatedAt,
                deletedAt: element.deletedAt,
                name: element.name,
                version: element.version,
                description: element.description,
                type: element.type,
                tenantId: element.tenantId,
                releaseNumber: element.releaseNumber,
                status: element.status,
                sections: AppReleaseSection.validStates(),
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            )
        }
    }

    static func invalidStates() -> [AppRelease] {
        return []
    }
}
