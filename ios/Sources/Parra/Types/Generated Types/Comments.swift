//
//  Comments.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import Foundation

public struct ParraUserStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        tenantId: String,
        name: String?,
        displayName: String,
        avatar: ParraImageAsset?,
        verified: Bool?,
        roles: [ParraUserRoleStub]?
    ) {
        self.id = id
        self.tenantId = tenantId
        self.name = name
        self.displayName = displayName
        self.avatar = avatar
        self.verified = verified
        self.roles = .init(roles)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.tenantId = try container.decode(String.self, forKey: .tenantId)

        self.name = try container.decodeIfPresent(String.self, forKey: .name)

        if let displayName = try container.decodeIfPresent(
            String.self,
            forKey: .displayName
        ) {
            self.displayName = displayName
        } else {
            if let name {
                self.displayName = name
            } else {
                if let first = id.split(separator: "-").first,
                   let num = Int(first, radix: 16)
                {
                    self.displayName = "User \(num)"
                } else {
                    self.displayName = "Unknown User"
                }
            }
        }

        self.avatar = try container
            .decodeIfPresent(ParraImageAsset.self, forKey: .avatar)
        self.verified = try container
            .decodeIfPresent(Bool.self, forKey: .verified)
        self.roles = try container
            .decodeIfPresent(
                PartiallyDecodableArray<ParraUserRoleStub>.self,
                forKey: .roles
            )
    }

    // MARK: - Public

    public let id: String
    public let tenantId: String
    public let name: String?
    public let displayName: String
    public let avatar: ParraImageAsset?
    public let verified: Bool?
    public let roles: PartiallyDecodableArray<ParraUserRoleStub>?
}

public struct ParraUserRoleStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        key: String
    ) {
        self.id = id
        self.name = name
        self.key = key
    }

    // MARK: - Public

    public let id: String
    public let name: String
    public let key: String
}

struct CreateCommentRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        body: String
    ) {
        self.body = body
    }

    // MARK: - Internal

    let body: String
}

public struct ParraCommentSummary: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        disabled: Bool,
        commentCount: Int
    ) {
        self.disabled = disabled
        self.commentCount = commentCount
    }

    // MARK: - Public

    public let disabled: Bool
    public let commentCount: Int
}

public struct ParraComment: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        body: String,
        userId: String,
        feedItemId: String?,
        user: ParraUserStub,
        reactions: [ParraReactionSummary]?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.body = body
        self.userId = userId
        self.feedItemId = feedItemId
        self.user = user
        self.reactions = .init(reactions)
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let body: String
    public let userId: String
    public let feedItemId: String?
    public let user: ParraUserStub
    public let reactions: PartiallyDecodableArray<ParraReactionSummary>?
}

struct UpdateCommentRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        body: String
    ) {
        self.body = body
    }

    // MARK: - Internal

    let body: String
}

struct FlagCommentRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        reason: String?
    ) {
        self.reason = reason
    }

    // MARK: - Internal

    let reason: String?
}

struct PaginateCommentsForFeedItemQuery: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        limit: Int,
        offset: Int,
        sort: String,
        createdAt: Date
    ) {
        self.limit = limit
        self.offset = offset
        self.sort = sort
        self.createdAt = createdAt
    }

    // MARK: - Internal

    let limit: Int
    let offset: Int
    let sort: String
    let createdAt: Date
}

struct PaginateCommentsCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ParraComment]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    let page: Int
    let pageCount: Int
    let pageSize: Int
    let totalCount: Int
    let data: PartiallyDecodableArray<ParraComment>
}
