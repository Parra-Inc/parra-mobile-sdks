//
//  Chat.swift
//  Parra
//
//  Created by Ian MacCallum on 2/4/25.
//

import Foundation

public struct CreatePaidDmChannelRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: String,
        key: String
    ) {
        self.type = type
        self.key = key
    }

    // MARK: - Public

    public let type: String
    public let key: String
}

public enum CreateChatChannelRequestBody: Codable, Equatable, Hashable {
    case createPaidDmChannelRequestBody(CreatePaidDmChannelRequestBody)

    // MARK: - Public

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .createPaidDmChannelRequestBody(let body):
            try container.encode(body)
        }
    }
}

public enum ChatChannelType: String, Codable {
    case dm
    case paidDm = "paid_dm"
    case `default`
    case app
    case group
    case user
}

public enum ChatChannelStatus: String, Codable {
    case active
    case closed
    case archived
}

public struct TenantUserStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        tenantId: String,
        name: String?,
        avatar: ParraImageAsset?,
        verified: Bool?,
        roles: [ParraUserRoleStub]?
    ) {
        self.id = id
        self.tenantId = tenantId
        self.name = name
        self.avatar = avatar
        self.verified = verified
        self.roles = .init(roles)
    }

    // MARK: - Public

    public let id: String
    public let tenantId: String
    public let name: String?
    public let avatar: ParraImageAsset?
    public let verified: Bool?
    public let roles: PartiallyDecodableArray<ParraUserRoleStub>?
}

public enum ChannelMemberType: String, Codable {
    case tenantUser = "tenant_user"
    case user
    case bot
}

public enum ChannelMemberRole: String, Codable {
    case admin
    case member
    case guest
}

public struct ChannelMember: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        user: TenantUserStub?,
        type: ChannelMemberType,
        roles: [ChannelMemberRole]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.user = user
        self.type = type
        self.roles = .init(roles)
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let user: TenantUserStub?
    public let type: ChannelMemberType
    public let roles: PartiallyDecodableArray<ChannelMemberRole>
}

public typealias ChannelResponse = Channel

public struct Channel: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        type: ChatChannelType,
        status: ChatChannelStatus,
        members: [ChannelMember]?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.type = type
        self.status = status
        self.members = .init(members)
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let type: ChatChannelType
    public let status: ChatChannelStatus
    public let members: PartiallyDecodableArray<ChannelMember>?
}

public struct ChannelCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [Channel]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Public

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: PartiallyDecodableArray<Channel>
}

public struct UpdateChatChannelRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        status: ChatChannelStatus
    ) {
        self.status = status
    }

    // MARK: - Public

    public let status: ChatChannelStatus
}

public struct MessageCollectionStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        channelId: String,
        memberId: String,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.channelId = channelId
        self.memberId = memberId
        self.content = content
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let channelId: String
    public let memberId: String
    public let content: String
}

public struct MessageCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [MessageCollectionStub]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Public

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: PartiallyDecodableArray<MessageCollectionStub>
}

public struct CreateMessageRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        content: String
    ) {
        self.content = content
    }

    // MARK: - Public

    public let content: String
}

public struct Message: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        channelId: String,
        memberId: String,
        user: TenantUserStub?,
        content: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.channelId = channelId
        self.memberId = memberId
        self.user = user
        self.content = content
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let channelId: String
    public let memberId: String
    public let user: TenantUserStub?
    public let content: String
}

public struct FlagMessageRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        reason: String?
    ) {
        self.reason = reason
    }

    // MARK: - Public

    public let reason: String?
}
