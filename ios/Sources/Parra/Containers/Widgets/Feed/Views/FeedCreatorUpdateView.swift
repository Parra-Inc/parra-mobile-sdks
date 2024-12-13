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
            VStack(spacing: 0) {
                if let sender = creatorUpdate.sender {
                    headerWithSender(sender)
                } else {
                    createdAt
                }

                withContent(content: creatorUpdate.title) { content in
                    componentFactory.buildLabel(
                        text: content,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .headline
                            ),
                            padding: .custom(
                                EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
                            ),
                            frame: .flexible(
                                FlexibleFrameAttributes(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            )
                        )
                    )
                }

                withContent(content: creatorUpdate.body) { content in
                    componentFactory.buildLabel(
                        text: content,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .body
                            ),
                            padding: .custom(
                                EdgeInsets(top: 3, leading: 0, bottom: 6, trailing: 0)
                            ),
                            frame: .flexible(
                                FlexibleFrameAttributes(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            )
                        )
                    )
                    .lineLimit(8)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding([.horizontal, .top], 16)

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

            VStack {
                FeedReactionView(
                    feedItemId: feedItemId,
                    reactionOptionGroups: reactionOptions,
                    reactions: reactions
                )
            }
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

    private var createdAt: some View {
        componentFactory.buildLabel(
            text: creatorUpdate.createdAt.timeAgo(),
            localAttributes: ParraAttributes.Label(
                text: .init(
                    style: .subheadline,
                    weight: .medium,
                    color: parraTheme.palette.secondaryText
                        .toParraColor()
                ),
                padding: .zero,
                frame: .flexible(
                    FlexibleFrameAttributes(maxWidth: .infinity, alignment: .leading)
                )
            )
        )
    }

    @ViewBuilder
    private func headerWithSender(
        _ sender: ParraCreatorUpdateSenderStub
    ) -> some View {
        HStack(spacing: 12) {
            if let avatar = sender.avatar {
                componentFactory.buildAsyncImage(
                    content: ParraAsyncImageContent(
                        avatar,
                        preferredThumbnailSize: .sm
                    )
                )
                .frame(
                    width: 46,
                    height: 46
                )
                .cornerRadius(25)
            }

            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    componentFactory.buildLabel(
                        text: sender.name,
                        localAttributes: ParraAttributes.Label(
                            text: .init(
                                style: .headline,
                                weight: .bold
                            ),
                            padding: .zero
                        )
                    )

                    if sender.verified == true {
                        componentFactory.buildImage(
                            content: .name("CheckBadgeSolid", .module, .template),
                            localAttributes: ParraAttributes
                                .Image(
                                    tint: .blue,
                                    size: CGSize(width: 20, height: 20)
                                )
                        )
                    }

                    Spacer()
                }

                createdAt
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }
}

struct TestView: View {
    // MARK: - Lifecycle

    init(model: TestModel) {
        self.model = model
    }

    // MARK: - Internal

    let model: TestModel

    var body: some View {
        EmptyView()
    }
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
