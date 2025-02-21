//
//  Chat.swift
//  Parra
//
//  Created by Ian MacCallum on 2/4/25.
//

import Foundation

struct CreatePaidDmChannelRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        type: String,
        key: String
    ) {
        self.type = type
        self.key = key
    }

    // MARK: - Internal

    let type: String
    let key: String
}

enum CreateChatChannelRequestBody: Codable, Equatable, Hashable {
    case createPaidDmChannelRequestBody(CreatePaidDmChannelRequestBody)

    // MARK: - Internal

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .createPaidDmChannelRequestBody(let body):
            try container.encode(body)
        }
    }
}

public enum ParraChatChannelType: String, Codable, CaseIterable {
    case dm
    case paidDm = "paid_dm"
    case `default`
    case app
    case group
    case user
}

enum ChatChannelStatus: String, Codable {
    case active
    case closed
    case archived
}

enum ChannelMemberType: String, Codable {
    /// A user of the app
    case tenantUser = "tenant_user"

    /// An admin of some type, sending a message from the dashboard
    case user

    case bot
}

enum ChannelMemberRole: String, Codable {
    case admin
    case member
    case guest
}

struct ChannelMember: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        user: ParraUserStub?,
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

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let user: ParraUserStub?
    let type: ChannelMemberType
    let roles: PartiallyDecodableArray<ChannelMemberRole>
}

typealias ChannelResponse = Channel

struct Channel: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String,
        type: ParraChatChannelType,
        status: ChatChannelStatus,
        members: [ChannelMember]?,
        latestMessages: [Message]?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.type = type
        self.status = status
        self.members = .init(members)
        self.latestMessages = .init(latestMessages)
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let type: ParraChatChannelType
    let status: ChatChannelStatus
    let members: PartiallyDecodableArray<ChannelMember>?
    var latestMessages: PartiallyDecodableArray<Message>?
}

struct ChannelCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
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

    // MARK: - Internal

    let page: Int
    let pageCount: Int
    let pageSize: Int
    let totalCount: Int
    let data: PartiallyDecodableArray<Channel>
}

struct UpdateChatChannelRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        status: ChatChannelStatus
    ) {
        self.status = status
    }

    // MARK: - Internal

    let status: ChatChannelStatus
}

struct MessageCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [Message]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Internal

    let page: Int
    let pageCount: Int
    let pageSize: Int
    let totalCount: Int
    let data: PartiallyDecodableArray<Message>
}

struct CreateMessageRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        content: String
    ) {
        self.content = content
    }

    // MARK: - Internal

    let content: String
}

struct Message: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        tenantId: String,
        channelId: String,
        memberId: String,
        user: ParraUserStub?,
        content: String,
        isTemporary: Bool? = nil,
        submissionErrorMessage: String? = nil
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
        self.isTemporary = isTemporary
        self.submissionErrorMessage = submissionErrorMessage
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let channelId: String
    let memberId: String
    let user: ParraUserStub?
    let content: String

    /// The comment has been created locally for display to the user but hasn't been stored in the database yet.
    let isTemporary: Bool?
    /// An error that occurred while sending this comment. Should only be sent
    /// when `isTemporary` is true
    var submissionErrorMessage: String?
}

struct FlagMessageRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        reason: String?
    ) {
        self.reason = reason
    }

    // MARK: - Internal

    let reason: String?
}
