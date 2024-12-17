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
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        name: String?,
        avatar: ParraImageAsset?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.name = name
        self.avatar = avatar
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let name: String?
    public let avatar: ParraImageAsset?
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
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        body: String,
        userId: String,
        user: ParraUserStub,
        reactions: [ParraReactionSummary]?,
        comments: ParraCommentSummary?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.body = body
        self.userId = userId
        self.user = user
        self.reactions = .init(reactions)
        self.comments = comments
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let body: String
    public let userId: String
    public let user: ParraUserStub
    public let reactions: PartiallyDecodableArray<ParraReactionSummary>?
    public let comments: ParraCommentSummary?
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
        createdAt: String
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
    let createdAt: String
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
