//
//  ExpandableMusicPlayer.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

struct ExpandableMusicPlayer: View {
    // MARK: - Internal

    var body: some View {
        ZStack(alignment: expandPlayer ? .top : .bottom) {
            if let media = player.currentMedia {
                MiniOverlayPlayer(
                    media: media,
                    expandPlayer: $expandPlayer
                ) {
                    withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                        expandPlayer = true
                    }
                }
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 5,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 5,
                    x: -5,
                    y: -5
                )
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $expandPlayer) {
            if let media = player.currentMedia {
                let feedItem = media.context.feedItem

                NavigationStack(
                    path: $navigationPath
                ) {
                    FeedRssItemDetailView(
                        rssItem: media.context.rssItem,
                        feedItem: feedItem,
                        reactor: StateObject(
                            wrappedValue: Reactor(
                                feedItemId: feedItem.id,
                                reactionOptionGroups: feedItem.reactionOptions?
                                    .elements ?? [],
                                reactions: feedItem.reactions?.elements ?? [],
                                api: parra.parraInternal.api,
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
                        ),
                        navigationPath: $navigationPath,
                        refreshOnAppear: true
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @State private var navigationPath: NavigationPath = .init()

    /// View Properties
    @State private var expandPlayer: Bool = false

    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
