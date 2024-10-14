//
//  Tenants.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct CreateTenantRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        isTest: Bool
    ) {
        self.name = name
        self.isTest = isTest
    }

    // MARK: - Public

    public let name: String
    public let isTest: Bool

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case name
        case isTest
    }
}

public struct ParraTenant: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        isTest: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.isTest = isTest
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let isTest: Bool

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case isTest
    }
}

struct TenantCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ParraTenant]
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
    public let data: [ParraTenant]

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

public struct ParraImageAssetStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        size: CGSize,
        url: URL
    ) {
        self.id = id
        self._size = _ParraSize(cgSize: size)
        self.url = url
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        self.id = try container.decode(String.self, forKey: .id)
        self._size = try container.decode(_ParraSize.self, forKey: .size)
        self.url = try container.decode(URL.self, forKey: .url)
    }

    // MARK: - Public

    public let id: String

    public let url: URL

    public var size: CGSize {
        return _size.toCGSize
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(_size, forKey: .size)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case size
        case url
    }

    // MARK: - Private

    private let _size: _ParraSize
}

public struct ParraIdentity: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        type: ParraIdentityType,
        provider: String?,
        providerUserId: String?,
        email: String?,
        emailVerified: Bool?,
        phoneNumber: String?,
        phoneNumberVerified: Bool?,
        username: String?,
        externalId: String?,
        hasPassword: Bool?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.type = type
        self.provider = provider
        self.providerUserId = providerUserId
        self.email = email
        self.emailVerified = emailVerified
        self.phoneNumber = phoneNumber
        self.phoneNumberVerified = phoneNumberVerified
        self.username = username
        self.externalId = externalId
        self.hasPassword = hasPassword
    }

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container
            .decodeIfPresent(String.self, forKey: .deletedAt)
        self.provider = try container
            .decodeIfPresent(String.self, forKey: .provider)
        self.providerUserId = try container
            .decodeIfPresent(String.self, forKey: .providerUserId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.emailVerified = try container
            .decodeIfPresent(Bool.self, forKey: .emailVerified)
        self.phoneNumber = try container
            .decodeIfPresent(String.self, forKey: .phoneNumber)
        self.phoneNumberVerified = try container
            .decodeIfPresent(Bool.self, forKey: .phoneNumberVerified)
        self.username = try container
            .decodeIfPresent(String.self, forKey: .username)
        self.externalId = try container
            .decodeIfPresent(String.self, forKey: .externalId)
        self.hasPassword = try container
            .decodeIfPresent(Bool.self, forKey: .hasPassword)

        do {
            self.type = try container.decode(ParraIdentityType.self, forKey: .type)
        } catch {
            Logger.warn(
                "Error decoding identity. Found unexpected type",
                error
            )

            self.type = .uknownIdentity
        }
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let type: ParraIdentityType
    public let provider: String?
    public let providerUserId: String?
    public let email: String?
    public let emailVerified: Bool?
    public let phoneNumber: String?
    public let phoneNumberVerified: Bool?
    public let username: String?
    public let externalId: String?
    public let hasPassword: Bool?

    public var name: String {
        switch type {
        case .username:
            return "Username"
        case .email:
            return "Email"
        case .phoneNumber:
            return "Phone"
        case .anonymous:
            return "Anonymous"
        case .uknownIdentity:
            return "Unknown"
        }
    }

    public var value: String? {
        switch type {
        case .username:
            return username
        case .email:
            return email
        case .phoneNumber:
            return phoneNumber
        case .anonymous:
            return "N/A"
        case .uknownIdentity:
            return "N/A"
        }
    }
}
