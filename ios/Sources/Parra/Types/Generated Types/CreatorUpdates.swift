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

enum CreatorUpdateVisibilityType: String, Codable, Hashable, Equatable, Sendable {
    case `public`
    case `private`
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
    let postVisibility: CreatorUpdateVisibilityType
    let attachmentVisibility: CreatorUpdateVisibilityType?
}

struct CreateCreatorUpdateRequestBody: Codable, Hashable, Equatable, Sendable {
    let publish: Bool?
    let templateId: String?
    let topic: CreatorUpdateTopic?
    let title: String?
    let body: String?
    let attachmentIds: PartiallyDecodableArray<String>?
    // Required when either post visibility or attachment visibility is set to private
    let entitlementId: String?
    let postVisibility: CreatorUpdateVisibilityType?
    let attachmentVisibility: CreatorUpdateVisibilityType?
}

struct CreatorUpdateTemplateStub: Codable, Hashable, Equatable, Sendable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let name: String
}

struct CreatorUpdateAttachmentStub: Codable, Hashable, Equatable, Sendable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
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
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let tenantId: String
    let name: String
    let verified: Bool
    let avatar: ParraImageAsset?
}

//    CreateCreatorUpdateRequestBody:
//      type: object
//      x-model: create-creator-update-request-body
//      properties:
//        publish:
//          type: boolean
//          description: If true, the creator update will be published immediately
//          nullable: true
//        template_id:
//          type: string
//          nullable: true
//        topic:
//          $ref: '#/components/schemas/CreatorUpdateTopic'
//          nullable: true
//        title:
//          type: string
//          nullable: true
//        body:
//          type: string
//          nullable: true
//        attachment_ids:
//          type: array
//          nullable: true
//          items:
//            type: string
//        entitlement_id:
//          type: string
//          nullable: true
//          description: Required when either post visibility or attachment visibility is set to private
//        post_visibility:
//          $ref: '#/components/schemas/CreatorUpdateVisibilityType'
//          nullable: true
//        attachment_visibility:
//          $ref: '#/components/schemas/CreatorUpdateVisibilityType'
//          nullable: true
//
//    UpdateCreatorUpdateRequestBody:
//      type: object
//      x-model: update-creator-update-request-body
//      properties:
//        title:
//          type: string
//        body:
//          type: string
//          nullable: true
//        topic:
//          $ref: '#/components/schemas/CreatorUpdateTopic'
//          nullable: true
//        entitlement_id:
//          type: string
//          nullable: true
//          description: Required when either post visibility or attachment visibility is set to private
//        post_visibility:
//          $ref: '#/components/schemas/CreatorUpdateVisibilityType'
//        attachment_visibility:
//          $ref: '#/components/schemas/CreatorUpdateVisibilityType'
//
//    CreatorUpdateStub:
//      type: object
//      x-model: creator-update-stub
//      allOf:
//        - $ref: "#/components/schemas/Entity"
//      required:
//        - title
//        - status
//        - tenant_id
//      properties:
//        tenant_id:
//          type: string
//        status:
//          $ref: '#/components/schemas/CreatorUpdateStatus'
//        topic:
//          $ref: '#/components/schemas/CreatorUpdateTopic'
//          nullable: true
//        title:
//          type: string
//        body:
//          type: string
//        scheduled_at:
//          type: string
//          format: date-time
//          nullable: true
//        sender:
//          $ref: '#/components/schemas/CreatorUpdateSenderStub'
//        template:
//          $ref: '#/components/schemas/CreatorUpdateTemplateStub'
//
//    CreatorUpdate:
//      type: object
//      x-model: creator-update
//      allOf:
//        - $ref: "#/components/schemas/Entity"
//      required:
//        - title
//        - status
//        - tenant_id
//        - attachments
//        - visibility
//        - channels
//      properties:
//        tenant_id:
//          type: string
//        status:
//          $ref: '#/components/schemas/CreatorUpdateStatus'
//        title:
//          type: string
//        body:
//          type: string
//        scheduled_at:
//          type: string
//          format: date-time
//          nullable: true
//        topic:
//          $ref: '#/components/schemas/CreatorUpdateTopic'
//          nullable: true
//        sender:
//          $ref: '#/components/schemas/CreatorUpdateSenderStub'
//        template:
//          $ref: '#/components/schemas/CreatorUpdateTemplateStub'
//        attachments:
//          type: array
//          items:
//            $ref: '#/components/schemas/CreatorUpdateAttachmentStub'
//        visibility:
//          $ref: '#/components/schemas/CreatorUpdateVisibility'
//        channels:
//          type: array
//          items:
//            $ref: '#/components/schemas/CreatorUpdateChannel'
