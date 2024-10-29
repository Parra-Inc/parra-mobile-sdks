//
//  Settings.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Foundation

struct SettingsItemIntegerData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        defaultValue: Int?,
        minValue: Int?,
        maxValue: Int?
    ) {
        self.defaultValue = defaultValue
        self.minValue = minValue
        self.maxValue = maxValue
    }

    // MARK: - Internal

    let defaultValue: Int?
    let minValue: Int?
    let maxValue: Int?
}

struct SettingsItemIntegerDataWithValue: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        defaultValue: Int?,
        minValue: Int?,
        maxValue: Int?,
        value: Int?
    ) {
        self.defaultValue = defaultValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.value = value
    }

    // MARK: - Internal

    let defaultValue: Int?
    let minValue: Int?
    let maxValue: Int?
    let value: Int?
}

struct SettingsItemStringDataEnumOption: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        title: String,
        value: String
    ) {
        self.title = title
        self.value = value
    }

    // MARK: - Internal

    let title: String
    let value: String
}

struct SettingsItemStringData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        enumOptions: [SettingsItemStringDataEnumOption]?,
        defaultValue: String?
    ) {
        self.format = format
        self.enumOptions = enumOptions
        self.defaultValue = defaultValue
    }

    // MARK: - Internal

    let format: String?
    let enumOptions: [SettingsItemStringDataEnumOption]?
    let defaultValue: String?
}

struct SettingsItemStringDataWithValue: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        enumOptions: [SettingsItemStringDataEnumOption]?,
        defaultValue: String?,
        value: String?
    ) {
        self.format = format
        self.enumOptions = enumOptions
        self.defaultValue = defaultValue
        self.value = value
    }

    // MARK: - Internal

    let format: String?
    let enumOptions: [SettingsItemStringDataEnumOption]?
    let defaultValue: String?
    let value: String?
}

struct SettingsItemBooleanData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        trueLabel: String?,
        falseLabel: String?,
        defaultValue: Bool?
    ) {
        self.format = format
        self.trueLabel = trueLabel
        self.falseLabel = falseLabel
        self.defaultValue = defaultValue
    }

    // MARK: - Internal

    let format: String?
    let trueLabel: String?
    let falseLabel: String?
    let defaultValue: Bool?
}

struct SettingsItemBooleanDataWithValue: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        trueLabel: String?,
        falseLabel: String?,
        defaultValue: Bool?,
        value: Bool?
    ) {
        self.format = format
        self.trueLabel = trueLabel
        self.falseLabel = falseLabel
        self.defaultValue = defaultValue
        self.value = value
    }

    // MARK: - Internal

    let format: String?
    let trueLabel: String?
    let falseLabel: String?
    let defaultValue: Bool?
    let value: Bool?
}

enum SettingsItemDataWithValue: Codable, Equatable, Hashable {
    case settingsItemIntegerDataWithValue(SettingsItemIntegerDataWithValue)
    case settingsItemStringDataWithValue(SettingsItemStringDataWithValue)
    case settingsItemBooleanDataWithValue(SettingsItemBooleanDataWithValue)
}

enum SettingsItemType: String, Codable {
    case string
    case boolean
    case integer
}

struct SettingsItemStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        groupId: String,
        viewId: String,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        slug: String,
        transportType: String?,
        key: String,
        type: SettingsItemType,
        required: Bool,
        nullable: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.groupId = groupId
        self.viewId = viewId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.slug = slug
        self.transportType = transportType
        self.key = key
        self.type = type
        self.required = required
        self.nullable = nullable
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let groupId: String
    let viewId: String
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let slug: String
    let transportType: String?
    let key: String
    let type: SettingsItemType
    let required: Bool
    let nullable: Bool
}

struct UserSettingsItem: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        groupId: String,
        viewId: String,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        slug: String,
        transportType: String?,
        key: String,
        type: SettingsItemType,
        required: Bool,
        nullable: Bool,
        data: SettingsItemDataWithValue
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.groupId = groupId
        self.viewId = viewId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.slug = slug
        self.transportType = transportType
        self.key = key
        self.type = type
        self.required = required
        self.nullable = nullable
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decode(Date.self, forKey: .deletedAt)
        self.groupId = try container.decode(String.self, forKey: .groupId)
        self.viewId = try container.decode(String.self, forKey: .viewId)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.displayTitle = try container.decode(String.self, forKey: .displayTitle)
        self.displayDescription = try container.decode(
            String.self,
            forKey: .displayDescription
        )
        self.slug = try container.decode(String.self, forKey: .slug)
        self.transportType = try container.decode(String.self, forKey: .transportType)
        self.key = try container.decode(String.self, forKey: .key)
        self.type = try container.decode(SettingsItemType.self, forKey: .type)
        self.required = try container.decode(Bool.self, forKey: .required)
        self.nullable = try container.decode(Bool.self, forKey: .nullable)

        switch type {
        case .boolean:
            self.data = try .settingsItemBooleanDataWithValue(
                container.decode(
                    SettingsItemBooleanDataWithValue.self,
                    forKey: .data
                )
            )
        case .integer:
            self.data = try .settingsItemIntegerDataWithValue(
                container.decode(
                    SettingsItemIntegerDataWithValue.self,
                    forKey: .data
                )
            )
        case .string:
            self.data = try .settingsItemStringDataWithValue(
                container.decode(
                    SettingsItemStringDataWithValue.self,
                    forKey: .data
                )
            )
        }
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let groupId: String
    let viewId: String
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let slug: String
    let transportType: String?
    let key: String
    let type: SettingsItemType
    let required: Bool
    let nullable: Bool
    let data: SettingsItemDataWithValue
}

struct SettingsGroupStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String?,
        viewId: String,
        notificationTopicId: String?,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        slug: String,
        key: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.viewId = viewId
        self.notificationTopicId = notificationTopicId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.slug = slug
        self.key = key
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String?
    let viewId: String
    let notificationTopicId: String?
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let slug: String
    let key: String
}

struct UserSettingsGroup: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String?,
        viewId: String,
        notificationTopicId: String?,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        slug: String,
        key: String,
        notificationTopic: NotificationTopic?,
        items: [UserSettingsItem]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.viewId = viewId
        self.notificationTopicId = notificationTopicId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.slug = slug
        self.key = key
        self.notificationTopic = notificationTopic
        self.items = items
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String?
    let viewId: String
    let notificationTopicId: String?
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let slug: String
    let key: String
    let notificationTopic: NotificationTopic?
    let items: [UserSettingsItem]
}

struct SettingsViewStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        footerLabel: String?,
        slug: String,
        type: String?,
        managed: Bool,
        active: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.footerLabel = footerLabel
        self.slug = slug
        self.type = type
        self.managed = managed
        self.active = active
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let footerLabel: String?
    let slug: String
    let type: String?
    let managed: Bool
    let active: Bool
}

struct UserSettingsView: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String,
        title: String,
        description: String?,
        displayTitle: String,
        displayDescription: String?,
        footerLabel: String?,
        slug: String,
        type: String?,
        managed: Bool,
        active: Bool,
        groups: [UserSettingsGroup]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.title = title
        self.description = description
        self.displayTitle = displayTitle
        self.displayDescription = displayDescription
        self.footerLabel = footerLabel
        self.slug = slug
        self.type = type
        self.managed = managed
        self.active = active
        self.groups = groups
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let title: String
    let description: String?
    let displayTitle: String
    let displayDescription: String?
    let footerLabel: String?
    let slug: String
    let type: String?
    let managed: Bool
    let active: Bool
    let groups: [UserSettingsGroup]
}
