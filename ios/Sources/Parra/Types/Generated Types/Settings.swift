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

public struct ParraSettingsItemIntegerDataWithValue: Codable, Equatable, Hashable {
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

    // MARK: - Public

    public let defaultValue: Int?
    public let minValue: Int?
    public let maxValue: Int?
    public let value: Int?
}

public struct ParraSettingsItemStringDataEnumOption: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        title: String,
        value: String
    ) {
        self.title = title
        self.value = value
    }

    // MARK: - Public

    public let title: String
    public let value: String
}

struct SettingsItemStringData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        enumOptions: [ParraSettingsItemStringDataEnumOption]?,
        defaultValue: String?
    ) {
        self.format = format
        self.enumOptions = enumOptions
        self.defaultValue = defaultValue
    }

    // MARK: - Internal

    let format: String?
    let enumOptions: [ParraSettingsItemStringDataEnumOption]?
    let defaultValue: String?
}

public struct ParraSettingsItemStringDataWithValue: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        format: String?,
        enumOptions: [ParraSettingsItemStringDataEnumOption]?,
        defaultValue: String?,
        value: String?
    ) {
        self.format = format
        self.enumOptions = enumOptions
        self.defaultValue = defaultValue
        self.value = value
    }

    // MARK: - Public

    public let format: String?
    public let enumOptions: [ParraSettingsItemStringDataEnumOption]?
    public let defaultValue: String?
    public let value: String?
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

public struct ParraSettingsItemBooleanDataWithValue: Codable, Equatable, Hashable {
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

    // MARK: - Public

    public let format: String?
    public let trueLabel: String?
    public let falseLabel: String?
    public let defaultValue: Bool?
    public let value: Bool?
}

public enum ParraSettingsItemDataWithValue: Codable, Equatable, Hashable {
    case settingsItemIntegerDataWithValue(ParraSettingsItemIntegerDataWithValue)
    case settingsItemStringDataWithValue(ParraSettingsItemStringDataWithValue)
    case settingsItemBooleanDataWithValue(ParraSettingsItemBooleanDataWithValue)
}

public enum ParraSettingsItemType: String, Codable {
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
        type: ParraSettingsItemType,
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
    let type: ParraSettingsItemType
    let required: Bool
    let nullable: Bool
}

public struct ParraUserSettingsItem: Codable, Equatable, Hashable, Identifiable {
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
        type: ParraSettingsItemType,
        required: Bool,
        nullable: Bool,
        data: ParraSettingsItemDataWithValue
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

    public init(from decoder: Decoder) throws {
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
        self.type = try container.decode(ParraSettingsItemType.self, forKey: .type)
        self.required = try container.decode(Bool.self, forKey: .required)
        self.nullable = try container.decode(Bool.self, forKey: .nullable)

        switch type {
        case .boolean:
            self.data = try .settingsItemBooleanDataWithValue(
                container.decode(
                    ParraSettingsItemBooleanDataWithValue.self,
                    forKey: .data
                )
            )
        case .integer:
            self.data = try .settingsItemIntegerDataWithValue(
                container.decode(
                    ParraSettingsItemIntegerDataWithValue.self,
                    forKey: .data
                )
            )
        case .string:
            self.data = try .settingsItemStringDataWithValue(
                container.decode(
                    ParraSettingsItemStringDataWithValue.self,
                    forKey: .data
                )
            )
        }
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let groupId: String
    public let viewId: String
    public let title: String
    public let description: String?
    public let displayTitle: String
    public let displayDescription: String?
    public let slug: String
    public let transportType: String?
    public let key: String
    public let type: ParraSettingsItemType
    public let required: Bool
    public let nullable: Bool
    public let data: ParraSettingsItemDataWithValue
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

public struct ParraUserSettingsGroup: Codable, Equatable, Hashable, Identifiable {
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
        notificationTopic: ParraNotificationTopic?,
        items: [ParraUserSettingsItem]
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

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let tenantId: String?
    public let viewId: String
    public let notificationTopicId: String?
    public let title: String
    public let description: String?
    public let displayTitle: String
    public let displayDescription: String?
    public let slug: String
    public let key: String
    public let notificationTopic: ParraNotificationTopic?
    public let items: [ParraUserSettingsItem]
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

public struct ParraUserSettingsLayout: Codable, Equatable, Hashable, Identifiable {
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
        groups: [ParraUserSettingsGroup]
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

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let tenantId: String
    public let title: String
    public let description: String?
    public let displayTitle: String
    public let displayDescription: String?
    public let footerLabel: String?
    public let slug: String
    public let type: String?
    public let managed: Bool
    public let active: Bool
    public let groups: [ParraUserSettingsGroup]
}
