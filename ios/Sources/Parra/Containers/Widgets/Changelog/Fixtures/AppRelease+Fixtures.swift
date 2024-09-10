//
//  AppRelease+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// MARK: - AppRelease + ParraFixture

extension ParraAppRelease: ParraFixture {
    static func validStates() -> [ParraAppRelease] {
        return AppReleaseStub.validStates().enumerated().map { _, element in
            return ParraAppRelease(
                id: element.id,
                createdAt: element.createdAt,
                updatedAt: element.updatedAt,
                deletedAt: element.deletedAt,
                name: element.name,
                version: element.version,
                description: element.description,
                type: element.type.value,
                tenantId: element.tenantId,
                releaseNumber: element.releaseNumber,
                status: element.status.value,
                sections: ParraAppReleaseSection.validStates(),
                header: ParraReleaseHeader(
                    id: "release-rocket-1",
                    size: ParraSize(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            )
        }
    }

    static func invalidStates() -> [ParraAppRelease] {
        return []
    }
}
