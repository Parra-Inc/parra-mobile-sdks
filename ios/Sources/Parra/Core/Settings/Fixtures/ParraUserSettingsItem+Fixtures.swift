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
            ),
            ParraUserSettingsItem(
                id: .uuid,
                createdAt: .now.daysAgo(1),
                updatedAt: .now.daysAgo(1),
                deletedAt: nil,
                groupId: .uuid,
                viewId: .uuid,
                title: "Updates per game",
                description: "The max number of updates you want to receive for each game.",
                slug: "updates",
                key: "notifications.picks.max",
                type: .integer,
                required: true,
                nullable: false,
                data: .settingsItemIntegerDataWithValue(
                    ParraSettingsItemIntegerDataWithValue(
                        defaultValue: 2,
                        minValue: 1,
                        maxValue: 100,
                        value: 4
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
                title: "Updates per week",
                description: "The max number of updates you want to receive per week.",
                slug: "updates-weekly",
                key: "notifications.picks.weekly",
                type: .integer,
                required: true,
                nullable: false,
                data: .settingsItemIntegerDataWithValue(
                    ParraSettingsItemIntegerDataWithValue(
                        defaultValue: 5,
                        minValue: 0,
                        maxValue: 20,
                        value: 2
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
                title: "Name in pushes",
                description: "The name you'd prefer to be addressed as.",
                slug: "name",
                key: "notifications.personalization.name",
                type: .string,
                required: true,
                nullable: false,
                data: .settingsItemStringDataWithValue(
                    ParraSettingsItemStringDataWithValue(
                        format: nil,
                        enumOptions: nil,
                        defaultValue: "default mick",
                        value: nil
                    )
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraUserSettingsItem] {
        return []
    }
}
