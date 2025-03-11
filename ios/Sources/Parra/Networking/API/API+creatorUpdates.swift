//
//  API+creatorUpdates.swift
//  Parra
//
//  Created by Mick MacCallum on 3/3/25.
//

import Foundation

extension API {
    func getCreatorUpdateTemplates() async throws
        -> CreatorUpdateTemplateCollectionResponse
    {
        return try await hitEndpoint(
            .getPaginateCreatorUpdateTemplates
        )
    }

    @discardableResult
    func postCreateCreatorUpdate(
        publish: Bool? = nil,
        scheduleAt: Date? = nil,
        templateId: String? = nil,
        topic: CreatorUpdateTopic? = nil,
        title: String? = nil,
        body: String? = nil,
        attachmentIds: [String]? = nil,
        entitlementId: String? = nil,
        postVisibility: CreatorUpdateVisibilityType? = nil,
        attachmentVisibility: CreatorUpdateVisibilityType? = nil
    ) async throws -> CreatorUpdate {
        let body = CreateCreatorUpdateRequestBody(
            publish: publish,
            scheduleAt: scheduleAt,
            templateId: templateId,
            topic: topic,
            title: title,
            body: body,
            attachmentIds: attachmentIds,
            entitlementId: entitlementId,
            postVisibility: postVisibility,
            attachmentVisibility: attachmentVisibility
        )

        return try await hitEndpoint(
            .postCreateCreatorUpdate,
            body: body
        )
    }
}
