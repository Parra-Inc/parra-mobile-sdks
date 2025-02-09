//
//  Notifications.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct NotificationRecipient: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        userId: String?
    ) {
        self.userId = userId
    }

    // MARK: - Public

    public let userId: String?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case userId
    }
}

struct CreateNotificationRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: [String: ParraAnyCodable]?,
        action: [String: ParraAnyCodable]?,
        deduplicationId: String?,
        groupId: String?,
        visible: Bool?,
        silent: Bool?,
        contentAvailable: Bool?,
        expiresAt: String?,
        recipients: [NotificationRecipient]
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageUrl = imageUrl
        self.data = data
        self.action = action
        self.deduplicationId = deduplicationId
        self.groupId = groupId
        self.visible = visible
        self.silent = silent
        self.contentAvailable = contentAvailable
        self.expiresAt = expiresAt
        self.recipients = recipients
    }

    // MARK: - Public

    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: [String: ParraAnyCodable]?
    public let action: [String: ParraAnyCodable]?
    public let deduplicationId: String?
    public let groupId: String?
    public let visible: Bool?
    public let silent: Bool?
    public let contentAvailable: Bool?
    public let expiresAt: String?
    public let recipients: [NotificationRecipient]

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl
        case data
        case action
        case deduplicationId
        case groupId
        case visible
        case silent
        case contentAvailable
        case expiresAt
        case recipients
    }
}

struct NotificationResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: [String: ParraAnyCodable]?,
        action: [String: ParraAnyCodable]?,
        deduplicationId: String?,
        groupId: String?,
        visible: Bool?,
        silent: Bool?,
        contentAvailable: Bool?,
        expiresAt: String?,
        userId: String?,
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        viewedAt: String?,
        version: String?
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageUrl = imageUrl
        self.data = data
        self.action = action
        self.deduplicationId = deduplicationId
        self.groupId = groupId
        self.visible = visible
        self.silent = silent
        self.contentAvailable = contentAvailable
        self.expiresAt = expiresAt
        self.userId = userId
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.viewedAt = viewedAt
        self.version = version
    }

    // MARK: - Public

    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: [String: ParraAnyCodable]?
    public let action: [String: ParraAnyCodable]?
    public let deduplicationId: String?
    public let groupId: String?
    public let visible: Bool?
    public let silent: Bool?
    public let contentAvailable: Bool?
    public let expiresAt: String?
    public let userId: String?
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let viewedAt: String?
    public let version: String?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl
        case data
        case action
        case deduplicationId
        case groupId
        case visible
        case silent
        case contentAvailable
        case expiresAt
        case userId
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case viewedAt
        case version
    }
}

struct NotificationCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [NotificationResponse]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [NotificationResponse]

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

struct ReadNotificationsRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        notificationIds: [String]
    ) {
        self.notificationIds = notificationIds
    }

    // MARK: - Public

    public let notificationIds: [String]

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case notificationIds
    }
}

struct CreatePushTokenRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        userId: String?,
        apnsToken: String
    ) {
        self.userId = userId
        self.apnsToken = apnsToken
    }

    // MARK: - Public

    public let userId: String?
    public let apnsToken: String

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case userId
        case apnsToken
    }
}

public struct ParraNotificationTopic: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        slug: String,
        description: String?,
        active: Bool?,
        tenantId: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.slug = slug
        self.description = description
        self.active = active
        self.tenantId = tenantId
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let slug: String
    public let description: String?
    public let active: Bool?
    public let tenantId: String
}
