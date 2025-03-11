//
//  CreatorUpdates.swift
//  Parra
//
//  Created by Mick MacCallum on 3/3/25.
//

import Foundation

enum CreatorUpdateStatus: String, Codable, Hashable, Equatable, Sendable {
    case draft
    case published
    case scheduled
}

enum CreatorUpdateTopic: String, Codable, Hashable, Equatable, Sendable {
    case giveaway
    case live
    case general
}

enum CreatorUpdateVisibilityType: String, Codable, Hashable, Equatable, Sendable,
    CaseIterable, Identifiable
{
    case `public`
    case `private`

    // MARK: - Internal

    var id: String {
        return rawValue
    }

    var composerName: String {
        switch self {
        case .public:
            return "Everyone"
        case .private:
            return "Subscribers"
        }
    }
}

enum CreatorUpdateChannelType: String, Codable, Hashable, Equatable, Sendable {
    case feed
    case notification
}

struct CreatorUpdateChannelFeedData: Codable, Hashable, Equatable, Sendable {
    let feedViewId: String
    let feedItemReactionsDisabled: Bool
    let feedItemCommentsDisabled: Bool
}

struct CreatorUpdateChannelNotificationData: Codable, Hashable, Equatable, Sendable {
    let notificationTemplateId: String
    let notificationTitle: String?
    let notificationBody: String?
}

enum CreatorUpdateChannelData: Codable, Hashable, Equatable, Sendable {
    case feed(CreatorUpdateChannelFeedData)
    case notification(CreatorUpdateChannelNotificationData)
}

struct CreatorUpdateVisibility: Codable, Hashable, Equatable, Sendable {
    let entitlementId: String?
    let paywallContext: String?
    var postVisibility: CreatorUpdateVisibilityType
    var attachmentVisibility: CreatorUpdateVisibilityType?
}

struct CreateCreatorUpdateRequestBody: Codable, Hashable, Equatable, Sendable {
    /// If true, the creator update will be published immediately
    let publish: Bool?

    /// Can only be passed if publish is not present
    let scheduleAt: Date?
    let templateId: String?
    let topic: CreatorUpdateTopic?
    let title: String?
    let body: String?
    let attachmentIds: [String]?
    // Required when either post visibility or attachment visibility is set to private
    let entitlementId: String?
    let postVisibility: CreatorUpdateVisibilityType?
    let attachmentVisibility: CreatorUpdateVisibilityType?
}

struct CreatorUpdateTemplateCollectionResponse: Codable, Hashable, Equatable, Sendable {
    let data: PartiallyDecodableArray<CreatorUpdateTemplate>
}

struct CreatorUpdateTemplate: Codable, Hashable, Equatable, Sendable, Identifiable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let name: String
    let tenantId: String
    let senderId: String?
    let feedViewId: String?
    let notificationTemplateId: String?
    let topic: CreatorUpdateTopic?
    let title: String?
    let body: String?
    let visibility: CreatorUpdateVisibility
}

struct CreatorUpdateTemplateStub: Codable, Hashable, Equatable, Sendable {
    let id: String
    let name: String
}

struct CreatorUpdateAttachmentStub: Codable, Hashable, Equatable, Sendable, Identifiable {
    let id: String
    let image: ParraImageAsset?
}

struct CreatorUpdate: Codable, Hashable, Equatable, Sendable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let title: String
    let body: String
    let status: CreatorUpdateStatus
    let scheduledAt: Date?
    let sender: CreatorUpdateSender?
    let template: CreatorUpdateTemplateStub?
    let attachments: PartiallyDecodableArray<CreatorUpdateAttachmentStub>
    let visibility: CreatorUpdateVisibility
    let topic: CreatorUpdateTopic?
    let channels: PartiallyDecodableArray<CreatorUpdateChannel>
}

struct CreatorUpdateChannel: Codable, Hashable, Equatable, Sendable {
    // MARK: - Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container
            .decodeIfPresent(Date.self, forKey: .deletedAt)
        self.type = try container
            .decode(CreatorUpdateChannelType.self, forKey: .type)
        self.delivered = try container
            .decodeIfPresent(Bool.self, forKey: .delivered)
        self.deliveredAt = try container
            .decodeIfPresent(Date.self, forKey: .deliveredAt)
        self.disabled = try container
            .decodeIfPresent(Bool.self, forKey: .disabled)

        switch type {
        case .feed:
            self.data = try .feed(
                container.decode(
                    CreatorUpdateChannelFeedData.self,
                    forKey: .data
                )
            )
        case .notification:
            self.data = try .notification(
                container.decode(
                    CreatorUpdateChannelNotificationData.self,
                    forKey: .data
                )
            )
        }
    }

    // MARK: - Internal

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let type: CreatorUpdateChannelType
    let data: CreatorUpdateChannelData
    let delivered: Bool?
    let deliveredAt: Date?
    let disabled: Bool?
}

struct CreatorUpdateSender: Codable, Hashable, Equatable, Sendable {
    let id: String
    let name: String
    let verified: Bool?
    let avatar: ParraImageAsset?
}
