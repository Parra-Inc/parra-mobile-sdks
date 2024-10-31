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
                title: "Personalization Preferences",
                description: "How you'd like to see your push notifications formatted.",
                slug: "personalization",
                key: "notifications.personalization",
                items: Array(ParraUserSettingsItem.validStates()[6...])
            ),
            ParraUserSettingsGroup(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                tenantId: .uuid,
                viewId: .uuid,
                title: "Sports Betting Picks",
                description: "Get live updates when I call my plays. These updats really give you the upper hand.",
                slug: "picks",
                key: "notifications.picks",
                items: Array(ParraUserSettingsItem.validStates()[4 ... 5])
            ),
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
                items: Array(ParraUserSettingsItem.validStates()[0 ... 3])
            )
        ]
    }

    public static func invalidStates() -> [ParraUserSettingsGroup] {
        return []
    }
}
