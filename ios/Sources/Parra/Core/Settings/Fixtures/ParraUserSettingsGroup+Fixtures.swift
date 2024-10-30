//
//  ParraUserSettingsGroup+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 10/30/24.
//

import SwiftUI

extension ParraUserSettingsGroup: ParraFixture {
    public static func validStates() -> [ParraUserSettingsGroup] {
        return [
            ParraUserSettingsGroup(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                tenantId: .uuid,
                viewId: .uuid,
                title: "Promotions",
                description: "Notifications promoting new items in the store.",
                slug: "promotions",
                key: "notifications.promotions",
                items: ParraUserSettingsItem.validStates()
            )
        ]
    }

    public static func invalidStates() -> [ParraUserSettingsGroup] {
        return []
    }
}
