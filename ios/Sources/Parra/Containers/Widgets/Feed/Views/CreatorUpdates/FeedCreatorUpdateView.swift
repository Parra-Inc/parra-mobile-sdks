//
//  FeedCreatorUpdateView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/25/24.
//

import SwiftUI

struct FeedCreatorUpdateView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItemId: String
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        VStack(spacing: 0) {
            FeedCreatorUpdateHeaderView(
                creatorUpdate: creatorUpdate
            )
            .padding([.horizontal, .top], 16)

            FeedCreatorUpdateContentView(
                creatorUpdate: creatorUpdate
            )
            .padding(.horizontal, 16)

            if let attachments = creatorUpdate.attachments?.elements,
               !attachments.isEmpty
            {
                ParraPaywalledContentView(
                    entitlement: creatorUpdate.attachmentPaywall?.entitlement,
                    context: creatorUpdate.attachmentPaywall?.context
                ) { requiredEntitlement, unlock in
                    CreatorUpdateAttachmentsView(
                        attachments: attachments,
                        containerGeometry: containerGeometry,
                        requiredEntitlement: requiredEntitlement
                    ) {
                        do {
                            try await unlock()
                        } catch {
                            Logger.error("Error unlocking attachment", error)
                        }
                    }
                } unlockedContentBuilder: {
                    CreatorUpdateAttachmentsView(
                        attachments: attachments,
                        containerGeometry: containerGeometry
                    )
                }
                .padding(.top, 8)
            }

            FeedReactionView(
                feedItemId: feedItemId,
                reactionOptionGroups: reactionOptions,
                reactions: reactions
            )
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .padding(.vertical, spacing)
        .safeAreaPadding(.horizontal)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}

public struct TestModel: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String?,
        body: String?,
        sender: ParraCreatorUpdateSenderStub?,
        attachments: [ParraCreatorUpdateAttachmentStub]?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.body = body
        self.sender = sender
        self.attachments = .init(attachments ?? [])
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String?
    public let body: String?
    public let sender: ParraCreatorUpdateSenderStub?
    public let attachments: PartiallyDecodableArray<ParraCreatorUpdateAttachmentStub>?
}

#Preview {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                FeedCreatorUpdateView(
                    creatorUpdate: ParraCreatorUpdateAppStub.validStates()[0],
                    feedItemId: .uuid,
                    reactionOptions: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    containerGeometry: proxy,
                    spacing: 18,
                    performActionForFeedItemData: { _ in }
                )
            }
        }
    }
}
