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

    // MARK: - Internal

    var rawValue: ParraAnyCodable {
        switch self {
        case .settingsItemIntegerDataWithValue(let data):
            return ParraAnyCodable(data.value)
        case .settingsItemStringDataWithValue(let data):
            return ParraAnyCodable(data.value)
        case .settingsItemBooleanDataWithValue(let data):
            return ParraAnyCodable(data.value)
        }
    }
}

public enum ParraSettingsItemType: String, Codable {
    case string
    case boolean
    case integer
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
        slug: String,
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
        self.slug = slug
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
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.groupId = try container.decode(String.self, forKey: .groupId)
        self.viewId = try container.decode(String.self, forKey: .viewId)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(
            String.self,
            forKey: .description
        )
        self.slug = try container.decode(String.self, forKey: .slug)
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
    public let slug: String
    public let key: String
    public let type: ParraSettingsItemType
    public let required: Bool
    public let nullable: Bool
    public let data: ParraSettingsItemDataWithValue
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
        title: String,
        description: String?,
        slug: String,
        key: String,
        items: [ParraUserSettingsItem]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.viewId = viewId
        self.title = title
        self.description = description
        self.slug = slug
        self.key = key
        self.items = items
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let tenantId: String?
    public let viewId: String
    public let title: String
    public let description: String?
    public let slug: String
    public let key: String
    public let items: [ParraUserSettingsItem]
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
        footerLabel: String?,
        slug: String,
        groups: [ParraUserSettingsGroup]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.title = title
        self.description = description
        self.footerLabel = footerLabel
        self.slug = slug
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
    public let footerLabel: String?
    public let slug: String
    public let groups: [ParraUserSettingsGroup]
}
