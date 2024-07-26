//
//  Tenants.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct CreateTenantRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        isTest: Bool
    ) {
        self.name = name
        self.isTest = isTest
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case name
        case isTest
    }

    public let name: String
    public let isTest: Bool
}

public struct Tenant: Codable, Equatable, Hashable, Identifiable {
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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case isTest
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let isTest: Bool
}

public struct TenantCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [Tenant]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
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
    public let data: [Tenant]
}

public struct ImageAssetStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        size: Size,
        url: URL
    ) {
        self.id = id
        self.size = size
        self.url = url
    }

    // MARK: - Public

    public let id: String
    public let size: Size
    public let url: URL
}

public struct Identity: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        type: IdentityType,
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

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let type: IdentityType
    public let provider: String?
    public let providerUserId: String?
    public let email: String?
    public let emailVerified: Bool?
    public let phoneNumber: String?
    public let phoneNumberVerified: Bool?
    public let username: String?
    public let externalId: String?
    public let hasPassword: Bool?
}