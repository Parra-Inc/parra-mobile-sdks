//
//  ParraUserSettingsItem+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 10/30/24.
//

import SwiftUI

extension ParraUserSettingsItem: ParraFixture {
    public static func validStates() -> [ParraUserSettingsItem] {
        return [
            ParraUserSettingsItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                groupId: .uuid,
                viewId: .uuid,
                title: "Email",
                description: "Send email notifications for Promotions",
                slug: "email",
                key: "notifications.promotions.email",
                type: .boolean,
                required: true,
                nullable: false,
                data: .settingsItemBooleanDataWithValue(
                    ParraSettingsItemBooleanDataWithValue(
                        format: nil,
                        trueLabel: nil,
                        falseLabel: nil,
                        defaultValue: true,
                        value: true
                    )
                )
            ),
            ParraUserSettingsItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                groupId: .uuid,
                viewId: .uuid,
                title: "Inbox",
                description: "Send inbox notifications for Promotions",
                slug: "inbox",
                key: "notifications.promotions.inbox",
                type: .boolean,
                required: true,
                nullable: false,
                data: .settingsItemBooleanDataWithValue(
                    ParraSettingsItemBooleanDataWithValue(
                        format: nil,
                        trueLabel: nil,
                        falseLabel: nil,
                        defaultValue: true,
                        value: true
                    )
                )
            ),
            ParraUserSettingsItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                groupId: .uuid,
                viewId: .uuid,
                title: "Push",
                description: "Send push notifications for Promotions",
                slug: "push",
                key: "notifications.promotions.push",
                type: .boolean,
                required: true,
                nullable: false,
                data: .settingsItemBooleanDataWithValue(
                    ParraSettingsItemBooleanDataWithValue(
                        format: nil,
                        trueLabel: nil,
                        falseLabel: nil,
                        defaultValue: true,
                        value: true
                    )
                )
            ),
            ParraUserSettingsItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                groupId: .uuid,
                viewId: .uuid,
                title: "SMS",
                description: "Send SMS notifications for Promotions",
                slug: "sms",
                key: "notifications.promotions.sms",
                type: .boolean,
                required: true,
                nullable: false,
                data: .settingsItemBooleanDataWithValue(
                    ParraSettingsItemBooleanDataWithValue(
                        format: nil,
                        trueLabel: nil,
                        falseLabel: nil,
                        defaultValue: true,
                        value: true
                    )
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraUserSettingsItem] {
        return []
    }
}
