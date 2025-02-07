//
//  File.swift
//  Parra
//
//  Created by Ian MacCallum on 2/4/25.
//

import Foundation

public struct CreatePaidDmChannelRequestBody: Codable, Equatable, Hashable {
    public let type: String
    public let key: String

    public init(
        type: String,
        key: String
    ) {
        self.type = type
        self.key = key
    }
}

public enum CreateChatChannelRequestBody: Codable, Equatable, Hashable {
    case createPaidDmChannelRequestBody(CreatePaidDmChannelRequestBody)
}

public enum ChatChannelType: String, Codable {
    case dm = "dm"
    case paidDm = "paid_dm"
    case `default` = "default"
    case app = "app"
    case group = "group"
    case user = "user"
}

public enum ChatChannelStatus: String, Codable {
    case active = "active"
    case closed = "closed"
    case archived = "archived"
}

public struct TenantUserStub: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let tenantId: String
    public let name: String?
    public let avatar: ParraImageAsset?
    public let verified: Bool?
    public let roles: Array<ParraUserRoleStub>?

    public init(
        id: String,
        tenantId: String,
        name: String?,
        avatar: ParraImageAsset?,
        verified: Bool?,
        roles: Array<ParraUserRoleStub>?
    ) {
        self.id = id
        self.tenantId = tenantId
        self.name = name
        self.avatar = avatar
        self.verified = verified
        self.roles = roles
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case name
        case avatar
        case verified
        case roles
    }
}

public enum ChannelMemberType: String, Codable {
    case tenantUser = "tenant_user"
    case user = "user"
    case bot = "bot"
}

public enum ChannelMemberRole: String, Codable {
    case admin = "admin"
    case member = "member"
    case guest = "guest"
}

public struct ChannelMember: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let user: TenantUserStub?
    public let type: ChannelMemberType
    public let roles: Array<ChannelMemberRole>

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        user: TenantUserStub?,
        type: ChannelMemberType,
        roles: Array<ChannelMemberRole>
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.user = user
        self.type = type
        self.roles = roles
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case user
        case type
        case roles
    }
}

public struct Channel: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let type: ChatChannelType
    public let status: ChatChannelStatus
    public let members: Array<ChannelMember>?

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        type: ChatChannelType,
        status: ChatChannelStatus,
        members: Array<ChannelMember>?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.type = type
        self.status = status
        self.members = members
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case tenantId = "tenant_id"
        case type
        case status
        case members
    }
}

public struct ChannelCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<Channel>

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<Channel>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct UpdateChatChannelRequestBody: Codable, Equatable, Hashable {
    public let status: ChatChannelStatus

    public init(
        status: ChatChannelStatus
    ) {
        self.status = status
    }
}

public struct MessageCollectionStub: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let channelId: String
    public let memberId: String
    public let content: String

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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case tenantId = "tenant_id"
        case channelId = "channel_id"
        case memberId = "member_id"
        case content
    }
}

public struct MessageCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<MessageCollectionStub>

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<MessageCollectionStub>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct CreateMessageRequestBody: Codable, Equatable, Hashable {
    public let content: String

    public init(
        content: String
    ) {
        self.content = content
    }
}

public struct Message: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let channelId: String
    public let memberId: String
    public let user: TenantUserStub?
    public let content: String

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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case tenantId = "tenant_id"
        case channelId = "channel_id"
        case memberId = "member_id"
        case user
        case content
    }
}

public struct FlagMessageRequestBody: Codable, Equatable, Hashable {
    public let reason: String?

    public init(
        reason: String?
    ) {
        self.reason = reason
    }
}

