//
//  FeedCreatorUpdateView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/25/24.
//

import SwiftUI

struct FeedCreatorUpdateDetailParams {
    var creatorUpdate: ParraCreatorUpdateAppStub
    var feedItem: ParraFeedItem
    var reactor: StateObject<Reactor>
}

struct FeedCreatorUpdateParams {
    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItem: ParraFeedItem
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void
    let performCreatorUpdateSelection: (
        _ detailParams: FeedCreatorUpdateDetailParams
    ) -> Void
    let api: API
}

struct FeedCreatorUpdateView: View {
    // MARK: - Lifecycle

    init(
        params: FeedCreatorUpdateParams
    ) {
        self.params = params
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: params.feedItem.id,
                reactionOptionGroups: params.reactionOptions ?? [],
                reactions: params.reactions ?? [],
                api: params.api,
                submitReaction: { api, itemId, reactionOptionId in
                    return try await api.addFeedReaction(
                        feedItemId: itemId,
                        reactionOptionId: reactionOptionId
                    )
                },
                removeReaction: { api, itemId, reactionId in
                    try await api.removeFeedReaction(
                        feedItemId: itemId,
                        reactionId: reactionId
                    )
                }
            )
        )
    }

    // MARK: - Internal

    let params: FeedCreatorUpdateParams

    var hasPaywallEntitlement: Bool {
        return entitlements.hasEntitlement(
            creatorUpdate.attachmentPaywall?.entitlement
        )
    }

    var body: some View {
        CellButton(
            action: {
                params.performCreatorUpdateSelection(
                    FeedCreatorUpdateDetailParams(
                        creatorUpdate: params.creatorUpdate,
                        feedItem: params.feedItem,
                        reactor: _reactor
                    )
                )
            }
        ) {
            VStack(spacing: 0) {
                FeedCreatorUpdateHeaderView(
                    creatorUpdate: creatorUpdate
                )
                .padding([.horizontal, .top], 16)

                FeedCreatorUpdateContentView(
                    creatorUpdate: creatorUpdate,
                    lineLimit: 8
                )
                .padding(.horizontal, 16)
                .padding(.bottom, hasAttachments || !hasReactions ? 12 : 0)

                if let attachments = creatorUpdate.attachments?.elements,
                   !attachments.isEmpty
                {
                    ParraPaywalledContentView(
                        entitlement: creatorUpdate.attachmentPaywall?.entitlement,
                        context: creatorUpdate.attachmentPaywall?.context
                    ) { requiredEntitlement, unlock in
                        CreatorUpdateAttachmentsView(
                            attachments: attachments,
                            containerGeometry: params.containerGeometry,
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
                            containerGeometry: params.containerGeometry
                        )
                    }
                }

                let showCommentCount = if let comments = params.feedItem.comments,
                                          !comments.disabled
                {
                    true
                } else {
                    false
                }

                if hasReactions {
                    FeedReactionView(
                        feedItem: params.feedItem,
                        reactor: _reactor,
                        showCommentCount: showCommentCount,
                        attachmentPaywall: creatorUpdate.attachmentPaywall
                    )
                    .padding(.top, hasAttachments ? 16 : 8)
                    .padding([.horizontal, .bottom], 16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
        }
        .disabled(redactionReasons.contains(.placeholder) && hasPaywallEntitlement)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .padding(.vertical, params.spacing)
        .safeAreaPadding(.horizontal)
    }

    // MARK: - Private

    @State private var isPresentingModal: Bool = false
    @StateObject private var reactor: Reactor

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.parraUserEntitlements) private var entitlements

    private var hasAttachments: Bool {
        guard let attachments = creatorUpdate.attachments?.elements else {
            return false
        }

        return !attachments.isEmpty
    }

    private var hasReactions: Bool {
        return reactor.showReactions
    }

    private var creatorUpdate: ParraCreatorUpdateAppStub {
        return params.creatorUpdate
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
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        GeometryReader { proxy in
            ScrollView {
                ForEach(ParraFeedItem.validStates()) { feedItem in
                    switch feedItem.data {
                    case .creatorUpdate(let creatorUpdate):
                        FeedCreatorUpdateView(
                            params: FeedCreatorUpdateParams(
                                creatorUpdate: creatorUpdate,
                                feedItem: feedItem,
                                reactionOptions: feedItem.reactionOptions?.elements,
                                reactions: feedItem.reactions?.elements,
                                containerGeometry: proxy,
                                spacing: 18.0,
                                performActionForFeedItemData: { _ in },
                                performCreatorUpdateSelection: { _ in },
                                api: parra.parraInternal.api
                            )
                        )
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}
