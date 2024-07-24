//
//  AppReleaseStub+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AppReleaseStub: ParraFixture {
    static func validStates() -> [AppReleaseStub] {
        return [
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                name: "March 2024",
                version: "2.3.0",
                description: "You asked for it, and we delivered! This release includes a ton of new features and bug fixes.",
                type: .minor,
                tenantId: UUID().uuidString,
                releaseNumber: 6,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(30),
                updatedAt: .now.daysAgo(15),
                deletedAt: nil,
                name: "February 2024",
                version: "2.2.2",
                description: "We missed some bugs in the last release, but we're confident we've squashed them all this time.",
                type: .patch,
                tenantId: UUID().uuidString,
                releaseNumber: 5,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(60),
                updatedAt: .now.daysAgo(30),
                deletedAt: nil,
                name: "January 2024",
                version: "2.2.1",
                description: "Just a few bug fixes and performance improvements",
                type: .patch,
                tenantId: UUID().uuidString,
                releaseNumber: 4,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(90),
                updatedAt: .now.daysAgo(60),
                deletedAt: nil,
                name: "December 2023",
                version: "2.2.0",
                description: "Even more new features and enhancements!",
                type: .minor,
                tenantId: UUID().uuidString,
                releaseNumber: 3,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(120),
                updatedAt: .now.daysAgo(90),
                deletedAt: nil,
                name: "November 2023",
                version: "2.1.0",
                description: "Added new features and fixed some bugs.",
                type: .minor,
                tenantId: UUID().uuidString,
                releaseNumber: 2,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(150),
                updatedAt: .now.daysAgo(120),
                deletedAt: nil,
                name: "October 2023",
                version: "2.0.0",
                description: "A whole lot of new features and improvements!",
                type: .major,
                tenantId: UUID().uuidString,
                releaseNumber: 1,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            ),
            AppReleaseStub(
                id: UUID().uuidString,
                createdAt: .now.daysAgo(150),
                updatedAt: .now.daysAgo(120),
                deletedAt: nil,
                name: "Septempter 2023",
                version: "1.0.0",
                description: "We're excited to release the first version of Parra!",
                type: .launch,
                tenantId: UUID().uuidString,
                releaseNumber: 1,
                status: .released,
                header: ReleaseHeader(
                    id: "release-rocket-1",
                    size: Size(width: 1_242, height: 699),
                    url: "https://images.unsplash.com/photo-1636819488524-1f019c4e1c44?q=100&w=1242"
                )
            )
        ]
    }

    static func invalidStates() -> [AppReleaseStub] {
        return []
    }
}
