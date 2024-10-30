//
//  ParraUserSettingsLayout+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 10/30/24.
//

import SwiftUI

extension ParraUserSettingsLayout: ParraFixture {
    public static func validStates() -> [ParraUserSettingsLayout] {
        return [
            ParraUserSettingsLayout(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                tenantId: .uuid,
                title: "Notifications",
                description: "Manage your notification preferences",
                footerLabel: "",
                slug: "notifications",
                groups: ParraUserSettingsGroup.validStates()
            )
        ]
    }

    public static func invalidStates() -> [ParraUserSettingsLayout] {
        return []
    }
}
