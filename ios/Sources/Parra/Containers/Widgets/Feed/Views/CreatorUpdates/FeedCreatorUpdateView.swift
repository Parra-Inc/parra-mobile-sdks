//
//  FeedCreatorUpdateView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/25/24.
//

import SwiftUI

struct FeedCreatorUpdateParams {
    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItem: ParraFeedItem
    let reactionOptions: [ParraReactionOptionGroup]?
    let reactions: [ParraReactionSummary]?
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void
}

struct FeedCreatorUpdateView: View {
    // MARK: - Lifecycle

    init(
        params: FeedCreatorUpdateParams
    ) {
        self.params = params
        self._reactor = ObservedObject(
            wrappedValue: Reactor(
                feedItemId: params.feedItem.id,
                reactionOptionGroups: params.reactionOptions ?? [],
                reactions: params.reactions ?? [],
                submitReaction: { api, itemId, reactionOptionId in
                    let response = try await api.addFeedReaction(
                        feedItemId: itemId,
                        reactionOptionId: reactionOptionId
                    )

                    return response.id
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

    var body: some View {
        let hasPaywallEntitlement = entitlements.hasEntitlement(
            creatorUpdate.attachmentPaywall?.entitlement
        )

        Button(action: {
            isPresentingModal = true
        }) {
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
                    .padding(.top, 8)
                }

                if reactor.showReactions {
                    FeedReactionView(
                        feedItemId: params.feedItem.id,
                        reactor: _reactor
                    )
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
        }
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .disabled(!redactionReasons.isEmpty && hasPaywallEntitlement)
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(.plain)
        .padding(.vertical, params.spacing)
        .safeAreaPadding(.horizontal)
        .sheet(isPresented: $isPresentingModal) {} content: {
            NavigationStack {
                FeedCreatorUpdateDetailView(
                    creatorUpdate: params.creatorUpdate,
                    feedItem: params.feedItem,
                    reactor: reactor
                )
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Private

    @State private var isPresentingModal: Bool = false
    @ObservedObject private var reactor: Reactor

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.parraUserEntitlements) private var entitlements

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
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                FeedCreatorUpdateView(
                    params: FeedCreatorUpdateParams(
                        creatorUpdate: ParraCreatorUpdateAppStub.validStates()[0],
                        feedItem: .validStates()[0],
                        reactionOptions: ParraReactionOptionGroup.validStates(),
                        reactions: ParraReactionSummary.validStates(),
                        containerGeometry: proxy,
                        spacing: 18,
                        performActionForFeedItemData: { _ in }
                    )
                )
            }
        }
    }
}
