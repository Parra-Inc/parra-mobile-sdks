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
                sections: AppReleaseSection.validStates()
            )
        }
    }

    static func invalidStates() -> [AppRelease] {
        return []
    }
}
