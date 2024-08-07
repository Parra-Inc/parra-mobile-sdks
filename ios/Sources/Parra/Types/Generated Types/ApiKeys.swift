//
//  ApiKeys.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct CreateApiKeyRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        description: String?
    ) {
        self.name = name
        self.description = description
    }

    // MARK: - Public

    public let name: String
    public let description: String?
}

struct ApiKey: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        description: String?,
        tenantId: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.description = description
        self.tenantId = tenantId
    }

    // MARK: - Public

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
}

struct ApiKeyWithSecretResponse: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        description: String?,
        tenantId: String,
        secret: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.description = description
        self.tenantId = tenantId
        self.secret = secret
    }

    // MARK: - Public

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
        case secret
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
    public let secret: String
}

struct ApiKeyCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ApiKey]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [ApiKey]
}
